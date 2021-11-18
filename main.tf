// Copyright © 2021 Daniel Morris
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

locals {
  // Refer to the README for information on obtaining the thumbprint.
  github_thumbprint = "A031C46782E6E6C662C2C87C76DA9AA62CCABD8E"
}

resource "aws_iam_role" "github" {
  count = var.enabled ? 1 : 0

  assume_role_policy    = data.aws_iam_policy_document.github[0].json
  description           = "Role used by the ${var.github_organisation}/${var.github_repository} GitHub repository."
  force_detach_policies = var.force_detach_policies
  managed_policy_arns   = var.managed_policy_arns
  max_session_duration  = var.max_session_duration
  name                  = var.iam_role_name
  path                  = var.iam_role_path
  tags                  = var.tags
}

resource "aws_iam_policy" "github" {
  count = var.enabled ? 1 : 0

  description = "Policy for the ${var.iam_role_name} role."
  name        = var.iam_policy_name
  path        = var.iam_policy_path
  policy      = data.aws_iam_policy_document.github[0].json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "github" {
  count = var.enabled ? 1 : 0

  policy_arn = aws_iam_policy.github[0].arn
  role       = aws_iam_role.github[0].name
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enabled ? 1 : 0

  client_id_list  = ["https://github.com/${var.github_organisation}"]
  tags            = var.tags
  thumbprint_list = [local.github_thumbprint]
  url             = "https://token.actions.githubusercontent.com"
}
