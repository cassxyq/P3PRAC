[
    {
      "name"      : "${var.prefix}-container-td",
      "image"     : "${appimage_URL}",
      "cpu"       : 256,
      "memory"    : 512,
      "essential" : true,
      "portMapping" : [
        {
          "containerPort" : "${var.app_port}",
          "hostPort"      : "${var.app_port}"
        }
      ]
    }
]