resource "aws_cognito_resource_server" "m2m_poc_server" {
  name         = "m2m-poc-server"
  identifier   = "https://m2m-poc-server"
  user_pool_id = aws_cognito_user_pool.m2m_poc_user_pool.id
  scope {
    scope_name        = "read"
    scope_description = "Read access"
  }
  scope {
    scope_name        = "write"
    scope_description = "Write access"
  }
}
