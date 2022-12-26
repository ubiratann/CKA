resource "google_compute_instance" "nodes" {
  count = length(var.nodes_map)

  name = var.nodes_map[count.index].name

  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = (var.nodes_map[count.index].is_master ? file(var.master_script) : file(var.worker_script))

  metadata = {
    ssh-keys = "${var.gce_username}:${file(var.gce_ssh_key_file_path)}"
  }
}
