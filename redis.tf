resource "aws_elasticache_subnet_group" "redis" {
  name       = "${local.environment}-redis-subnet"
  subnet_ids = local.elasticache_subnets
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${local.environment}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_names = [aws_security_group.redis.name]
}

resource "aws_security_group" "redis" {
  name        =  "${local.environment}-redis-sg"
  description = "Allow "

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = local.private_cidr_blocks
    description = "Redis access"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}