resource oci_devops_deploy_environment export_Demo-OKE-US-env {
  cluster_id = "ocid1.cluster.oc1.iad.aaaaaaaa3s7cdjobliane4uataxhnixq5xw3imznjn3x7sz6scvjtcwxmmta"
  deploy_environment_type = "OKE_CLUSTER"
  description             = ""
  display_name            = "Demo-OKE-US-env"
  project_id = oci_devops_project.export_DevOps-Demo.id
}

resource oci_devops_deploy_pipeline export_Deploy-OKE-ADB-US {
  deploy_pipeline_parameters {
    items {
      default_value = "n7djxxqbnkflnvn_adbdemo_high.adb.oraclecloud.com"
      description   = ""
      name          = "DB_SERVICE_NAME"
    }
    items {
      default_value = "kf4c11fo.adb.us-ashburn-1.oraclecloud.com"
      description   = ""
      name          = "DB_HOST"
    }
    items {
      default_value = "Oracle1234567"
      description   = ""
      name          = "DB_PASSWORD"
    }
    items {
      default_value = "admin"
      description   = ""
      name          = "DB_USER"
    }
    items {
      default_value = "1.0.0"
      description   = ""
      name          = "APP_VERSION"
    }
  }
  description  = ""
  display_name = "Deploy-OKE-ADB-US"
  project_id = oci_devops_project.export_DevOps-Demo.id
}

resource oci_devops_deploy_stage export_Apply-SQL {
  command_spec_deploy_artifact_id = oci_devops_deploy_artifact.export_Apply_SQL_to_ADB_shell.id
  container_config {
    availability_domain   = "bxtG:US-ASHBURN-AD-1"
    compartment_id        = var.compartment_ocid
    container_config_type = "CONTAINER_INSTANCE_CONFIG"
    network_channel {
      network_channel_type = "SERVICE_VNIC_CHANNEL"
      nsg_ids = [
      ]
      subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaawjfteo3hqoiq76y7vsq5sfhjunyrza6rfljjptqi7q56tjf5wxja"
    }
    shape_config {
      memory_in_gbs = "4"
      ocpus         = "2"
    }
    shape_name = "CI.Standard.E4.Flex"
  }
  deploy_pipeline_id = oci_devops_deploy_pipeline.export_Deploy-OKE-ADB-US.id
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_pipeline.export_Deploy-OKE-ADB-US.id
    }
  }
  deploy_stage_type = "SHELL"
  description  = ""
  display_name = "Apply SQL"
  timeout_in_seconds = "36000"
}


resource oci_devops_deploy_stage export_Deploy-app-to-OKE {

  deploy_pipeline_id = oci_devops_deploy_pipeline.export_Deploy-OKE-ADB-US.id
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_stage.export_Apply-SQL.id
    }
  }
  deploy_stage_type = "OKE_DEPLOYMENT"
  description  = ""
  display_name = "Deploy app to OKE"

  kubernetes_manifest_deploy_artifact_ids = [
    oci_devops_deploy_artifact.export_app-demo-oke-manifest.id,
  ]
  oke_cluster_deploy_environment_id = oci_devops_deploy_environment.export_Demo-OKE-US-env.id
}