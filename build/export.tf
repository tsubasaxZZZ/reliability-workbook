//-------------------------------------------
// Export tab
//-------------------------------------------
locals {
  kql_export_summary_by_resource_environment = templatefile(
    "${path.module}/template_kql/export/export_summary_by_resource_environment.kql",
    {
      "calculate_score" = local.kql_calculate_score
      "extend_resource" = local.kql_extend_resource
      "summarize_score" = local.kql_summarize_score
    }
  )
  // Resources Details
  kql_export_resources_details = templatefile(
    "${path.module}/template_kql/export/export_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  workbook_export_json = templatefile("${path.module}/templates/export.tpl.json", {
    "kql_export_summary_by_resource_environment" = jsonencode(local.kql_export_summary_by_resource_environment)
    "kql_export_resources_details"               = jsonencode(local.kql_export_resources_details)
    "kql_advisor_resource"                       = jsonencode(local.kql_advisor_resource)
  })
}

resource "random_uuid" "workbook_name_export" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-export"
  }
}

resource "local_file" "export" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookExport.json"
  content  = local.workbook_export_json
}