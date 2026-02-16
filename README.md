# Radius5共通Claude Code Plugin

Radius5社内で共通で使用しているプラグインのマーケットプレイスです。
ドメイン知識や、開発で使用している言語に依存しない仕様です。

r5プラグイン1つで全ての機能を提供します。

## 使い方
```
# マーケットプレイスの追加
/plugin marketplace add radius5-study/r5-plugin

# プラグインのインストール
/plugin install r5@r5-plugin
```

## プラグインリスト

### /pr-review
社内で共通で使用しているPull Requestのレビュー機能を提供するスキルです。
基本的にはGitHub Actionsで使用することを想定しています。

`gh` CLIを使用した構造化されたPRレビューワークフローを実行します。

**主な機能:**
- 差分の自動取得・ファイル分類（HIGH/MEDIUM/LOW/SKIP の優先度付け）
- 5,000行超のPRは自動スキップ、300行超は1ファイルずつインクリメンタルにレビュー
- 過去のClaudeレビューを検出し、新しい変更のみをレビュー（重複指摘の防止）
  - 永続化層にはGitHub Actionsのアーティファクトを使用します。
- セキュリティスキャン（ハードコードされたシークレット、インジェクション、危険なAPI使用の検出）
- マージ可否の判定と `gh pr review` による結果投稿（Approve / Request Changes / Comment）
- 指摘事項にはAI Fix Promptを添付（そのままAIエージェントにコピペして修正可能）

**呼び出し方:**
```
/pr-review <PR番号>
```

### atomic-pr
社内で使用している、PlanモードからPull Requestの粒度を細かくするためのhooksとagentです。  
[PRレビューで消耗しないためにClaude Codeのフックを使った話](https://zenn.dev/gibbs/articles/claude-code-atomic-pr-automation)をベースにしています。
