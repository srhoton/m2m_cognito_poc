resource "aws_cognito_user_pool_domain" "m2m_poc_domain" {
  domain       = "m2m-poc"
  user_pool_id = aws_cognito_user_pool.m2m_poc_user_pool.id
}
