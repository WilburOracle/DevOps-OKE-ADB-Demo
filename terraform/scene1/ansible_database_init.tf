# Ansible数据库初始化动作
# 此文件定义了一个本地执行的null_resource，用于初始化Oracle数据库

resource "null_resource" "database_initialization" {
  # 依赖于数据库资源创建完成
  depends_on = [
    oci_database_autonomous_database.export_ADB-Demo
  ]

  # 当init.sql文件内容变更时重新执行
  triggers = {
    init_sql_content = file("${path.module}/init.sql")
  }

  # 本地执行Ansible命令
  provisioner "local-exec" {
    command = <<-EOT
      # 创建临时的Ansible playbook
      cat > ansible_init_db.yml << 'EOF'
      ---\n      - name: 初始化Oracle数据库\n        hosts: localhost\n        gather_facts: false\n        vars:\n          db_host: "${oci_database_autonomous_database.export_ADB-Demo.private_endpoint_ip}"\n          db_port: 1521\n          db_service: "adbdemo_tp"\n          db_admin_user: "ADMIN"\n          db_admin_password: "${var.db_admin_password}"\n        tasks:\n          - name: 使用sqlplus执行初始化脚本\n            command: >\n              sqlplus -S "{{ db_admin_user }}/{{ db_admin_password }}@//{{ db_host }}:{{ db_port }}/{{ db_service }}" @init.sql\n            args:\n              chdir: "${path.module}"\n            register: sql_output\n            ignore_errors: true\n\n          - name: 显示SQL执行结果\n            debug:\n              var: sql_output.stdout\n\n          - name: 显示SQL错误（如果有）\n            debug:\n              var: sql_output.stderr\n            when: sql_output.rc != 0\n      EOF

      # 执行Ansible playbook
      ansible-playbook ansible_init_db.yml

      # 清理临时文件
      rm -f ansible_init_db.yml
    EOT

    # 在环境变量中设置必要的数据库连接信息
    environment = {
      # 注意：这里假设db_admin_password变量已在vars.tf中定义或通过其他方式传入
      # 如果需要，可以调整为使用Terraform的sensitive input
    }

    # 根据操作系统选择shell
    interpreter = ["/bin/bash", "-c"]
  }
}

# 输出数据库初始化状态
output "database_initialization_status" {
  value = "数据库初始化动作已配置完成，将在应用时执行Ansible命令初始化数据库。"
}

# 如果vars.tf中未定义db_admin_password变量，需要添加该变量定义
# 在实际使用中，请确保安全地管理数据库密码
variable "db_admin_password" {
  type        = string
  description = "Oracle数据库管理员密码"
  sensitive   = true
  default     = "" # 建议通过TF_VAR_db_admin_password环境变量或命令行参数传入
}