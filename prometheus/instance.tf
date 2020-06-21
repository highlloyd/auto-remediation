# Below resource is to create public key

resource "tls_private_key" "sskeygen_execution" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Below are the aws key pair
resource "aws_key_pair" "prometheus_key_pair" {
  depends_on = ["tls_private_key.sskeygen_execution"]
  key_name   = "${var.aws_public_key_name}"
  public_key = "${tls_private_key.sskeygen_execution.public_key_openssh}"
}


# prometheus instance
resource "aws_instance" "prometheus_instance" {
  ami               = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type     = "${var.aws_instance_type}"
  availability_zone = "${var.aws_availability_zone}"

  key_name               = "${aws_key_pair.prometheus_key_pair.id}"
  vpc_security_group_ids = ["${aws_security_group.prometheus_security_group.id}"]
  subnet_id              = "${aws_subnet.prometheus_subnet.id}"

  connection {
    user        = "ubuntu"
    host = self.public_ip
    private_key = "${tls_private_key.sskeygen_execution.private_key_pem}"
  }

# Copy the prometheus file to instance
  provisioner "file" {
    source      = "./prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }
# Install docker in the ubuntu
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt update",
      "sudo apt-get -y install docker.io",
      "sudo apt -y install docker-ce",
      "sudo docker swarm init",
      "git clone https://github.com/highlloyd/prometheus-grafana-alertmanager-example.git",
      "ls",
      "pwd",
      "cd prometheus-grafana-alertmanager-example/",
      "ls",
      "pwd",
      "sudo sed -i 's;<access_key>;${aws_iam_access_key.prometheus_access_key.id};g' prometheus/prometheus.yml",
      "sudo sed -i 's;<secret_key>;${aws_iam_access_key.prometheus_access_key.secret};g' prometheus/prometheus.yml",
      "sudo chmod +x ./util/*.sh",
      "sudo docker stack deploy -c docker-compose.yml prom",
      "wget https://github.com/prometheus/node_exporter/releases/download/v1.0.0/node_exporter-1.0.0.linux-amd64.tar.gz",
      "tar xvfz node_exporter-*.*-amd64.tar.gz",
      "sudo useradd -rs /bin/false node_exporter",
      "sudo cp node_exporter-1.0.0.linux-amd64/node_exporter /usr/local/bin",
      "sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter",
      "cd /etc/systemd/system",
      "sudo wget https://ronaldos3bucketaw.s3.amazonaws.com/node_exporter.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start node_exporter",
      "sudo systemctl enable node_exporter",

    ]
  }
  provisioner "local-exec" {
    command = "echo '${tls_private_key.sskeygen_execution.private_key_pem}' >> ${aws_key_pair.prometheus_key_pair.id}.pem ; chmod 400 ${aws_key_pair.prometheus_key_pair.id}.pem"
  }

  tags = {
    Name = "${var.name}_instance"
    Environment = "${var.env}"
  }
}
