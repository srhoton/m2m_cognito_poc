resource "aws_cognito_user_pool_client" "m2m_poc_client" {
  name                                 = "m2m-pool-client"
  user_pool_id                         = aws_cognito_user_pool.m2m_poc_user_pool.id
  generate_secret                      = true
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.m2m_poc_server.scope_identifiers
  callback_urls                        = ["https://localhost:3000"]
}
