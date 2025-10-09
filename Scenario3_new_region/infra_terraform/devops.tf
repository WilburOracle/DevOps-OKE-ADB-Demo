resource "oci_devops_deploy_environment" "oke_env" {
  provider = oci.home
  cluster_id = module.oke.cluster_id
  deploy_environment_type = "OKE_CLUSTER"
  display_name            = "Demo-OKE-${var.region_abbreviation}-env"
  project_id = var.devops_project_ocid
}

resource "oci_devops_deploy_pipeline" "deploy_pipeline" {
  provider = oci.home
  deploy_pipeline_parameters {
    items {
      name          = "DB_SERVICE_NAME"
      default_value = local.adb_service_name
    }
    items {
      name          = "DB_HOST"
      default_value = local.adb_host
    }
    items {
      name          = "DB_PASSWORD"
      default_value = var.db_password
    }
    items {
      name          = "DB_USER"
      default_value = "ouser"
    }
    items {
      name          = "APP_VERSION"
      default_value = var.app_version
    }
  }
  display_name = "Deploy-OKE-ADB-${var.region_abbreviation}"
  project_id = var.devops_project_ocid
}

resource "oci_devops_deploy_stage" "deploy_sql_stage" {
  provider = oci.home
  command_spec_deploy_artifact_id = var.devops_artifact_adb_sql_shell_ocid
  container_config {
    compartment_id        = var.compartment_ocid
    container_config_type = "CONTAINER_INSTANCE_CONFIG"
    network_channel {
      network_channel_type = "SERVICE_VNIC_CHANNEL"
      nsg_ids = [
        module.oke.worker_nsg_id
      ]
      subnet_id = module.oke.worker_subnet_id
    }
    shape_config {
      memory_in_gbs = "4"
      ocpus         = "2"
    }
    shape_name = "CI.Standard.E4.Flex"
  }
  deploy_pipeline_id = oci_devops_deploy_pipeline.deploy_pipeline.id
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_pipeline.deploy_pipeline.id
    }
  }
  deploy_stage_type = "SHELL"
  display_name = "Apply SQL"
  timeout_in_seconds = "36000"
}


resource "oci_devops_deploy_stage" "deploy_oke_stage" {
  provider = oci.home
  deploy_pipeline_id = oci_devops_deploy_pipeline.deploy_pipeline.id
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_stage.deploy_sql_stage.id
    }
  }
  deploy_stage_type = "OKE_DEPLOYMENT"
  display_name = "Deploy app to OKE"

  kubernetes_manifest_deploy_artifact_ids = [
    var.devops_artifact_oke_manifest_ocid,
  ]
  oke_cluster_deploy_environment_id = oci_devops_deploy_environment.oke_env.id
}
