#!groovy
node {
  def branch
  // デフォルトをセットするイディオム。
  // Rubyにおける hoge ||= 'fuga'
  def default_branch = env.DEFAULT_BRANCH_GIT ?: 'master'
  def app_repo_url = env.APP_REPO_URL
  def JENKINS_DATA_DIR = '/docker/jenkins'
  stage('Parameters') {
    try{
      timeout(time: 30, unit: 'SECONDS') {
        branch = input message: 'パラメータを入力して下さい',
          parameters: [
            string(defaultValue: default_branch, description: 'master develop', name: 'branch'),
          ]
      }
    } catch(err) {
      // タイムアウトエラーが起きたらデフォルトブランチをセットする
      branch = default_branch
    }
  }
  stage('Checkout') {
    checkout([$class: 'GitSCM', branches: [[name: "${branch}"]], userRemoteConfigs: [[url: "${app_repo_url}"]]])
  }
  stage('Build') {
    sh 'docker pull maven:3.5.2-jdk-8-alpine'
    withDockerContainer(
      args: "-v ${JENKINS_DATA_DIR}/workspace/deploy_app/complete:/usr/src/mymaven -w /usr/src/mymaven",
      image: 'maven:3.5.2-jdk-8-alpine'
    ) {
      sh 'mvn clean package -DskipTests=true'
    }
  }
  stage('Deploy') {
    sh 'docker pull java:8u111-jdk-alpine'
    // 前回起動したコンテナが残っていたら停止する
    // -a => 停止したものも含めてコンテナを表示
    sh """docker ps -a --filter name=gs-rest-service \
      | awk 'BEGIN{i=0}{i++;}END{if(i>=2)system("docker stop gs-rest-service")}'
    """
    // --rm => コンテナが停止したら自動的にコンテナを削除
    // -p ホストのポート:コンテナのポート => ポートをマッピングする
    // -v ホストのディレクトリ:コンテナのディレクトリ => ディレクトリを共有する
    // -w コンテナのディレクトリ => コンテナ起動時のワーキングディレクトリを指定する
    sh """docker run \
      --rm \
      --name gs-rest-service \
      -p 80:80 \
      -v ${JENKINS_DATA_DIR}/workspace/deploy_app:/usr/src/myapp \
      -w /usr/src/myapp \
      java:8u111-jdk-alpine java \
      -jar complete/target/gs-rest-service-0.1.0.jar \
      --server.port=80 &
    """
  }
}

