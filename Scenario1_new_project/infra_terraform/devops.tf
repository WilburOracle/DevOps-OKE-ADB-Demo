resource oci_devops_project export_DevOps-Demo {
  compartment_id = var.compartment_ocid
  defined_tags = {
    "default_tags.CreatedBy" = "oracleidentitycloudservice/wenbin.chen@oracle.com"
    "default_tags.CreatedOn" = "2025-09-19T08:42:43.441Z"
  }
  description = "A Devops project for OKE and ADB"
  freeform_tags = {
  }
  name = "DevOps-Demo"
  notification_config {
    topic_id = "ocid1.onstopic.oc1.iad.amaaaaaaak7gbria4pzk2qivdjs6hsjux5ed47wtypumrsgawjepzxydfhaa"
  }
}

resource oci_devops_deploy_environment oke_env {
  cluster_id = module.oke.cluster_id
  deploy_environment_type = "OKE_CLUSTER"
  description             = ""
  display_name            = "Demo-OKE-US-env"
  project_id = var.devops_project_ocid
}

resource oci_devops_deploy_pipeline deploy_pipeline {
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
      default_value = var.db_password
      description   = ""
      name          = "DB_PASSWORD"
    }
    items {
      default_value = "ouser"
      description   = ""
      name          = "DB_USER"
    }
    items {
      default_value = var.app_version
      description   = ""
      name          = "APP_VERSION"
    }
  }
  description  = ""
  display_name = "Deploy-OKE-ADB-US"
  project_id = var.devops_project_ocid
}

resource oci_devops_deploy_stage deploy_sql_stage {
  command_spec_deploy_artifact_id = oci_devops_deploy_artifact.export_Apply_SQL_to_ADB_shell.id
  container_config {
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
  deploy_pipeline_id = oci_devops_deploy_pipeline.deploy_pipeline.id
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_pipeline.deploy_pipeline.id
    }
  }
  deploy_stage_type = "SHELL"
  description  = ""
  display_name = "Apply SQL"
  timeout_in_seconds = "36000"
}


resource oci_devops_deploy_stage deploy_oke_stage {
  deploy_pipeline_id = oci_devops_deploy_pipeline.deploy_pipeline.id
  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_stage.deploy_sql_stage.id
    }
  }
  deploy_stage_type = "OKE_DEPLOYMENT"
  description  = ""
  display_name = "Deploy app to OKE"

  kubernetes_manifest_deploy_artifact_ids = [
    oci_devops_deploy_artifact.export_app-demo-oke-manifest.id,
  ]
  oke_cluster_deploy_environment_id = oci_devops_deploy_environment.oke_env.id
}

resource oci_devops_repository export_app-demo {
  default_branch = "refs/heads/main"
  name                 = "app-demo"
  project_id           = oci_devops_project.export_DevOps-Demo.id
  repository_type      = "HOSTED"
}

resource oci_devops_project_repository_setting export_DevOps-Demo_project_repository_setting {
  merge_settings {
    allowed_merge_strategies = [
      "MERGE_COMMIT",
    ]
    default_merge_strategy = "MERGE_COMMIT"
  }
  project_id = oci_devops_project.export_DevOps-Demo.id
}

resource oci_devops_deploy_artifact export_Apply_SQL_to_ADB_shell {
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_source {
    base64encoded_content = "version: 0.1\ncomponent: command\ntimeoutInSeconds: 3600\nshell: bash\nfailImmediatelyOnError: true\n\ninputArtifacts:\n  - name: \"app-demo-adb-sql\"\n    type: \"GENERIC_ARTIFACT\"\n    registryId: \"ocid1.artifactrepository.oc1.iad.0.amaaaaaaak7gbriaev2wihpkqknnbvvx2xm6oajzjf23kpzieoxt7gja2loa\"\n    path: \"app-demo-adb-sql.sql\"\n    version: \"$${APP_VERSION}\"\n    location:  \"app-demo-adb-sql.sql\"\n\nsteps:\n  - type: Command\n    name: \"Apply SQL to ADB\"\n    shell: bash\n    timeoutInSeconds: 300\n    failImmediatelyOnError: true\n    command: |\n      cat app-demo-adb-sql.sql\n      echo ' sql $${DB_USER}/$${DB_PASSWORD}@(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=$${DB_HOST}))(connect_data=(service_name=$${DB_SERVICE_NAME}))(security=(ssl_server_dn_match=no))) @app-demo-adb-sql.sql'\n      sql '$${DB_USER}/$${DB_PASSWORD}@(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=$${DB_HOST}))(connect_data=(service_name=$${DB_SERVICE_NAME}))(security=(ssl_server_dn_match=no)))' @app-demo-adb-sql.sql"
    deploy_artifact_source_type = "INLINE"
  }
  deploy_artifact_type = "COMMAND_SPEC"
  description          = ""
  display_name         = "Apply_SQL_to_ADB_shell"
  freeform_tags = {
  }
  project_id = oci_devops_project.export_DevOps-Demo.id
}

resource oci_devops_deploy_artifact export_app-demo-adb-sql {
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_source {
    deploy_artifact_path        = "app-demo-adb-sql.sql"
    deploy_artifact_source_type = "GENERIC_ARTIFACT"
    deploy_artifact_version     = "$${APP_VERSION}"
    repository_id = "ocid1.artifactrepository.oc1.iad.0.amaaaaaaak7gbriaev2wihpkqknnbvvx2xm6oajzjf23kpzieoxt7gja2loa"
  }
  deploy_artifact_type = "GENERIC_FILE"
  display_name         = "app-demo-adb-sql"
  project_id = oci_devops_project.export_DevOps-Demo.id
}

resource oci_devops_deploy_artifact export_app-demo-oke-manifest {
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_source {
    deploy_artifact_path        = "app-demo-oke-manifest.yaml"
    deploy_artifact_source_type = "GENERIC_ARTIFACT"
    deploy_artifact_version     = "$${APP_VERSION}"
    repository_id = "ocid1.artifactrepository.oc1.iad.0.amaaaaaaak7gbriaev2wihpkqknnbvvx2xm6oajzjf23kpzieoxt7gja2loa"
  }
  deploy_artifact_type = "KUBERNETES_MANIFEST"
  display_name         = "app-demo-oke-manifest"
  project_id = oci_devops_project.export_DevOps-Demo.id
}

resource oci_devops_deploy_artifact export_app-demo-image {
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_source {
    deploy_artifact_source_type = "OCIR"
    image_digest = ""
    image_uri    = "iad.ocir.io/sehubjapacprod/wilbur/devops/app-demo-image:$${APP_VERSION}"
  }
  deploy_artifact_type = "DOCKER_IMAGE"
  display_name         = "app-demo-image"
  project_id = oci_devops_project.export_DevOps-Demo.id
}

resource oci_devops_build_pipeline_stage export_deliver-artifacts {
  build_pipeline_id = oci_devops_build_pipeline.export_build-demo-app.id
  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline_stage.export_build-image.id
    }
  }
  build_pipeline_stage_type = "DELIVER_ARTIFACT"
  deliver_artifact_collection {
    items {
      artifact_id   = oci_devops_deploy_artifact.export_app-demo-image.id
      artifact_name = "app-demo-image"
    }
    items {
      artifact_id   = oci_devops_deploy_artifact.export_app-demo-adb-sql.id
      artifact_name = "app-demo-adb-sql"
    }
    items {
      artifact_id   = oci_devops_deploy_artifact.export_app-demo-oke-manifest.id
      artifact_name = "app-demo-oke-manifest"
    }
  }
  display_name = "deliver artifacts"
}

resource oci_devops_build_pipeline_stage export_build-image {
  build_pipeline_id = oci_devops_build_pipeline.export_build-demo-app.id
  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline.export_build-demo-app.id
    }
  }
  build_pipeline_stage_type = "BUILD"
  build_runner_shape_config {
    build_runner_type = "DEFAULT"
  }
  build_source_collection {
    items {
      branch = "main"
      connection_type = "DEVOPS_CODE_REPOSITORY"
      name            = "app-demo"
      repository_id   = oci_devops_repository.export_app-demo.id
      repository_url  = "https://devops.scmservice.us-ashburn-1.oci.oraclecloud.com/namespaces/sehubjapacprod/projects/DevOps-Demo/repositories/app-demo"
    }
  }
  build_spec_file = "build_spec.yaml"
  display_name = "build image"
  image = "OL8_X86_64_STANDARD_10"
  primary_build_source               = "app-demo"
  stage_execution_timeout_in_seconds = "600"
}

resource oci_devops_repository_setting export_app-demo_repository_setting {
  merge_checks {
    last_build_succeeded = "DISABLED"
  }
  merge_settings {
    allowed_merge_strategies = [
      "MERGE_COMMIT",
    ]
    default_merge_strategy = "MERGE_COMMIT"
  }
  repository_id = oci_devops_repository.export_app-demo.id
}