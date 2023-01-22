# helm-charts-practice

## このリポジトリについて

本リポジトリは、ArgoCDを使用してチャートをデプロイし、いろいろなチャートを検証するリポジトリです。

ついでに、ディレクトリの構成方法も学習します。

<br>

## 設計ポリシー

### ディレクトリ構成

ディレクトリ構成は以下の通りとします。

ユーザ定義のチャートは、```app```ディレクトリと```infra```ディレクトリ配下に配置しています。

一方で、公式チャートはチャートリポジトリ（GitHub Pagesなど）を参照しています。

複数のチャートから構成される一部のツール（Istioなど）、各チャートのリポジトリを監視する孫Applicationを用意し、これを子Applicationで管理しています。

```yaml
repository/
├── README.md
├── app # アプリ領域のマイクロサービスごとのユーザ定義チャートを配置
├── deploy
│   ├── argocd-app-child         # ArgoCDのアプリ領域の子Applicationを配置
│   ├── argocd-infra-child       # ArgoCDのインフラ領域の子Applicationを配置
│   ├── argocd-infra-grandchild  # ArgoCDのインフラ領域の孫Applicationを配置
│   ├── argocd-parent            # ArgoCDの親Applicationを配置
│   └── argocd-root              # ArgoCDのルートApplicationを配置
│
└── infra # インフラ領域のツールごとのユーザ定義チャートを配置
```

<br>

### ArgoCD

#### ▼ App-Of-Appsパターン

<img src="https://raw.githubusercontent.com/hiroki-it/helm-charts-practice/main/root-application.png" alt="root-application" style="zoom:80%;" />


ArgoCDでは、[App-Of-Appsパターン](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern)を採用しており、以下のようなApplication構成になっています。

```yaml
argocd-root
├── argocd-app-parent # アプリ領域のマイクロサービスごとのチャートをデプロイできる。
└── argocd-infra-parent # インフラ領域のツールごとのチャートをデプロイできる
```

ArgoCDのルートApplication（argocd-root）のみ、ArgoCDを使用してデプロイできないため、Helmfileを使用しています。


#### ▼ プロジェクト

ArgoCDでは、プロジェクト名でApplicationをフィルタリングできます。

これは、Applicationの選び間違えるといったヒューマンエラーを防ぐことにつながります。

今現在、以下のプロジェクトを定義しています。

- root
- app
- infra

#### ▼ 認証認可

認証認可方法には、SSOを採用しています。

認証フェーズの委譲先としてGitHubを選び、GitHubへの通信時のハブとして```dex-server```を使用しています。

```bash
$ kubectl get deployment -n argocd

NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
argocd-dex-server    1/1     1            1           41h # これ！
argocd-redis         1/1     1            1           41h
argocd-repo-server   1/1     1            1           41h
argocd-server        1/1     1            1           41h
```

<br>

## セットアップ

### ツールのインストール

```bash
$ asdf install
```

<br>


### Minikube

#### ▼ 起動

Minikubeを起動します。

```bash
$ minikube start --memory 12288 --cpus 8 --nodes 5 --container-runtime=containerd
```

#### ▼ コンテキスト

コンテキストを切り替えます。

```bash
$ kubectx minikube
```

#### ▼ ワーカーNodeの種類分け

node affinityのために、ワーカーNodeの```metadata.labels```キー配下にNodeの種類を表すラベルを付与します。


```bash
# minikube-m01はコントロールプレーンNodeのため、ラベルを付与しない。
$ kubectl label node minikube-m02 node.kubernetes.io/nodegroup=app \
  && kubectl label node minikube-m03 node.kubernetes.io/nodegroup=deploy \
  && kubectl label node minikube-m04 node.kubernetes.io/nodegroup=ingress \
  && kubectl label node minikube-m05 node.kubernetes.io/nodegroup=system
```

#### ▼ ネットワークツールの導入

マイクロサービスアーキテクチャでは、ネットワークのデバッグのために、Linuxのパッケージを使用することがあります。

Minikube仮想サーバーにツールをインストールします。

```bash
$ minikube ssh -- "sudo apt-get update -y && sudo apt-get install -y tcptraceroute"
```

<br>


### ArgoCD

#### ▼ デプロイ

```bash
$ cd deploy/argocd-root
$ helmfile -e dev -f helmfile.d/argocd.yaml diff
$ helmfile -e dev -f helmfile.d/argocd.yaml apply
```

```bash
$ cd deploy/argocd-root
$ helmfile -e dev -f helmfile.d/argocd-apps.yaml diff
$ helmfile -e dev -f helmfile.d/argocd-apps.yaml apply
```

#### ▼ ダッシュボードへのアクセス

本番環境ではIngressを介してダッシュボードを介してArgoCDのPodに接続します。

一方で開発環境のMinikube上では、Ingressを介さずに、ArgoCDのPodに直接的に接続します。

```bash
$ kubectl port-forward svc/argocd-server -n argocd 8080:443
```
