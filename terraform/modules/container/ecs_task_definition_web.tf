# NOTE: コメントアウトされている設定値の値は適当です

resource "aws_ecs_task_definition" "web_nginx" {
  ### ------------------------------
  ### タスク定義内のコンテナすべてで共有する設定
  ### ------------------------------
  family = "web-nginx"
  cpu    = "256" # 0.25vCPU
  memory = "512"

  track_latest = true

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.ecs_task_execution_web.arn
  task_role_arn      = aws_iam_role.ecs_task_web.arn

  # pid_mode = "task" # サイドカーコンテナと、プロセスやファイルシステムを共有したい場合はtaskを指定 (https://dev.classmethod.jp/articles/ecs-on-fargate-support-shared-pid-namespace/)
  # ipc_mode = "none" # IPC名前空間の共有範囲の設定。Fargateでは指定不可

  ### ------------------------------
  ### タスク定義内の各コンテナで個別に設定する設定
  ### ------------------------------
  container_definitions = jsonencode([
    {
      ### ------------------------------
      ### 基本情報
      ### ------------------------------
      "name" : "web-nginx",
      "image" : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/ecr-public/nginx/nginx:stable"

      ### リソース割り当て
      # "cpu" : "256"               # コンテナ単位の割り当てCPU
      # "memory" : "512"            # コンテナ単位の割り当てメモリ(ハードリミット)
      # "memoryReservation" : "512" # コンテナ単位の割り当てメモリ(ソフトリミット)。コンテナが確実に確保すべき最小メモリ量を指定
      # "resourceRequirements" : [] # GPUやInferenceAccelerator(機械学習モデルの推論高速化用の専用アクセラレーター)を明示的に割り当てる場合に利用

      ### ------------------------------
      ### ポートマッピング
      ### ------------------------------
      "portMappings" : [
        {
          # awsvpc network mode利用時は、hostPortは指定しない
          "containerPort" : 80,
          "protocol" : "tcp",
          # ECS Service Connect(Client mode)利用時は、nameの指定は不要
          # 今回構成では、webコンテナはALB経費でアクセスされるため、Client modeを利用
          # "name" : "web-nginx-ecs-service-connect"
        }
      ],

      ### ------------------------------
      ### 起動・停止設定
      ### ------------------------------
      "startTimeout" : 60, # コンテナの起動がタイムアウトするまでの時間
      "stopTimeout" : 30,  # コンテナが正常終了しなかった場合に、強制終了させるまでの時間

      "entryPoint" : ["sh", "-c"] # docker run コマンドの ENTRYPOINT に相当
      "command" = [
        "echo 'server { listen 80; location / { proxy_pass http://app-nginx-ecs-service-connect-80-tcp.example.local; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
      ] # docker run コマンドの CMD に相当。今回は、nginxの設定ファイルを書き換えて、port 80でのリクエストをappコンテナに転送する設定を追加(本来は設定ファイルを埋め込んだDockerイメージを利用するべきだが、簡易的に設定)
      # "workingDirectory" : "/"    # コンテナ内の作業ディレクトリを指定

      "essential" : true, # このコンテナが停止した場合、タスク全体を停止させるかどうか
      # "dependsOn" : []  # コンテナ間に開始・終了の依存関係がある場合に利用

      ### ------------------------------
      ### ECS Serviceが実行するHealthCheckの設定
      ### ------------------------------
      "healthCheck" : {
        "command" : ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
        "interval" : 10,
        "timeout" : 30,
        "retries" : 3,
        "startPeriod" : 15,
      },

      ### ------------------------------
      ### 権限関連
      ### ------------------------------
      "privileged" : false, # 特権モードの利用可否
      # "user" : "some user id or group id", # コンテナ内のプロセスを実行するユーザーを指定

      ### ------------------------------
      ### ログ設定
      ### ------------------------------
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : data.aws_region.current.name,
          "awslogs-group" : aws_cloudwatch_log_group.web_nginx.name,
          "awslogs-stream-prefix" : "web-nginx"
        }
      },
      # "firelensConfiguration" : {}, # FireLens(同じタスク定義内に定義したFluentdやFluent Bitコンテナにログを簡単に転送できる機能)を利用する場合に利用

      ### ------------------------------
      ### プライベートレジストリの認証情報
      ### ------------------------------
      # "credentialSpecs": "credentialspec:arn" # ECR以外のプライベートレジストリにアクセスする場合に利用。情報の格納先のSSM, S3のarnを指定
      # "repositoryCredentials": {
      #   "credentialsParameter": "arn"
      # },                                      # ECR以外のプライベートレジストリにアクセスする場合に利用。認証情報の格納先のSecrets Managerのarnを指定

      ### ------------------------------
      ### ネットワーク設定
      ### ------------------------------
      # "disableNetworking": false              # コンテナのネットワーク通信を禁止する場合に利用
      # "dnsSearchDomains": "example.internal"  # コンテナがDNS検索を行う際に自動追加するドメインを指定。例えば、example.internalを指定した状態でxxxxを解決すると、xxxx.example.internalが解決される
      # "dnsServers": ["10.0.0.2"]              # コンテナがDNS検索を行う際に利用するDNSサーバーを指定
      # "hostname" : "some-hostname",           # コンテナ内でのみ利用できるホスト名の割り当て設定。awsvpc network modeでは利用不可
      # "links" : ["container-name"],           # [deprecated] 同一タスク定義内のコンテナの名前解決を直接行う機能。Dockerの古い機能で非推奨
      # "extraHosts" : [
      #   {
      #     "hostname" : "example.com",
      #     "ipAddress" : "10.0.0.10"
      #   }
      # ],                                      # コンテナの /etc/hosts に追加するホスト情報

      ### ------------------------------
      ### 環境変数系
      ### ------------------------------
      # "environment" : [
      #   {
      #     "name" : "ENDPOINT_URL",
      #     "value" : "some-endpoint"
      #   },
      # ],                                      # 環境変数
      #
      # "environmentFiles" : [
      #   {
      #     "type" : "s3",
      #     "value" : "arn:aws:s3:::example-bucket/envfile"
      #   }
      # ],                                      # 環境変数をファイルからまとめて読み込む場合に利用
      # 
      # "secrets" : [
      #   {
      #     "name" : "SECRET_NAME",
      #     "valueFrom" : "arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:example-secret-123456"
      #   }
      # ],                                      # SSM Parameter Store, Secrets Managerのシークレット情報をコンテナに環境変数として渡す設定

      ### ------------------------------
      ### 高度な管理用の設定
      ### ------------------------------
      # "dockerLabels": {
      #   "key1": "value1",
      #   "key2": "value2"
      # },                                      # コンテナの管理用のラベル指定

      ### ------------------------------
      ### 対話型モード利用時の設定
      ### ------------------------------
      # "interactive" : false,                  # コンテナを対話型モードで実行する場合に利用
      # "pseudoTerminal" : false,               # コンテナを対話型モードで実行する場合に利用

      ### ------------------------------
      ### ボリュームの設定
      ### ------------------------------
      # "mountPoint" : [
      #   {
      #     "containerPath" : "/mnt",
      #     # volume parameterで設定したボリューム名を設定
      #     "sourceVolume" : "example",
      #     "readOnly" : true
      #   }
      # ],                                # ボリュームのマウント設定
      # "readonlyRootFilesystem" : false, # コンテナのルートファイルシステムを読み取り専用にする場合に利用
      # "volumesFrom" : [],               # 他のコンテナのボリュームをマウントし、ボリュームを共有する場合に利用

      ### ------------------------------
      ### LINUXの高度な設定
      ### ------------------------------
      # "linuxParameters" : {}, # Linuxのカーネルパラメータを設定する場合に利用
      # "systemControls" : [],  # Linuxのカーネルパラメータを設定する場合に利用。例えばAurora利用時にベストプラクティスに沿った設定にするために利用できる
      #                         # (https://dev.classmethod.jp/articles/ecs-on-fargate-support-systemcontrols/)
      # "ulimits" : [],         # ulimitで、リソース制限を設定する場合に利用
      # "dockerSecurityOptions" : [
      #   "label:type:container_runtime_t",
      #   "seccomp:unconfined"
      # ],                      # SELinuxのコンテキストやAppArmor、seccompプロファイルなどの応用的なセキュリティ設定を行う際に利用
    }
  ])
}
