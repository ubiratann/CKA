resource "google_compute_instance" "nodes" {
  count = length(var.nodes_map)

  name = var.nodes_map[count.index].name

  machine_type = (var.nodes_map[count.index].is_master ? var.master_instance_type : var.worker_instance_type)

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = "40"
    }

  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = (var.nodes_map[count.index].is_master ? file(var.master_script) : file(var.worker_script))

  metadata = {
    ssh-keys = "${var.gce_host_username}:${file(var.gce_ssh_key_file_path)}"
  }
}
