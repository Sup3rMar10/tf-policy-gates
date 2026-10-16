variable "filename" {
  type    = string
  default = "out/service.conf"
}

variable "file_permission" {
  type    = string
  default = "0640"
}

resource "local_file" "conf" {
  filename        = "${path.module}/${var.filename}"
  file_permission = var.file_permission
  content         = "listen = 8080\n"
}
