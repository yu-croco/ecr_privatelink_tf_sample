# ECR PrivateLink Terraform Sample
AWS ECRのPrivateLinkを利用して `<AWS Account>.dkr.ecr.<region>.amazonaws.com` からprivate通信（AWS内部の通信）でimageをpullするためのTerraformサンプル。

以下の構成図のような構成をTerraform化している。
![構成図](./img/structure.png "構成図")

InterfaceタイプのVPCエンドポイントは、それらを利用する側のリソースと同じVPC内部に配置していれば問題ない（ルーティングできれば良い）ので、役割を分けるためにsubnetごと分離している。

# 参考
- [エンドポイントを使用してプライベートサブネットでECSを使用する](https://dev.classmethod.jp/articles/privatesubnet_ecs/)
- [Amazon ECR インターフェイス VPC エンドポイント (AWS PrivateLink)](https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/vpc-endpoints.html)
