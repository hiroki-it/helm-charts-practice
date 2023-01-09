# helm-charts-practice

## このリポジトリについて

本リポジトリは、ArgoCDを使用してチャートをデプロイし、チャートの技術を学習するリポジトリです。

ついでに、ディレクトリの構成方法も学習します。

<br>

## ディレクトリ構成

ディレクトリ構成は以下の通りとします。

```yaml
.
├── Makefile
├── README.md
├── app # アプリ領域のマイクロサービスごとのチャート
├── deploy
│   ├── argocd-app-child     # ArgoCDのアプリ領域の子Application
│   ├── argocd-app-parent    # ArgoCDのアプリ領域の親Application
│   ├── argocd-infra-child   # ArgoCDのインフラ領域の子Application
│   ├── argocd-infra-parent  # ArgoCDのインフラ領域の親Application
│   └── argocd-root          # ArgoCDのルートApplication
│
└── infra # インフラ領域のツールごとのチャート
```

ArgoCDでは、App-Of-Appsパターンを採用しており、以下のようなApplication構成になっています。

```yaml
argocd-root
├── argocd-app-parent
│   └── argocd-app-child # アプリ領域のマイクロサービスごとのチャートをデプロイできる。
│
└── argocd-infra-parent
    └── argocd-infra-child # インフラ領域のツールごとのチャートをデプロイできる
```

ArgoCDのルートApplication（argocd-root）のみ、ArgoCDを使用してデプロイできないため、Helmfileを使用しています。

<br>

## セットアップ

### Minikube

Minikubeを起動する。

```bash
$ minikube start --memory 8192 --cpus 8 --nodes 2
```

### ArgoCD

#### デプロイ

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

#### ダッシュボードへのアクセス

dev環境では、追加で作成しているNodePort Serviceを介して、ArgoCDのダッシュボードに接続します。

返却されるURLにアクセスします。

```bash
$ minikube service argocd-server --url -n argocd
```
