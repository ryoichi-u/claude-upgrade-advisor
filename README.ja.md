# Claude Upgrade Advisor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) のリリースノートをセットアップと照合し、機能の採用・非推奨パターンの修正・設定改善を提案するプラグインです。

**[English README](README.md)**

## 課題

Claude Codeは頻繁にアップデートされ、新機能・非推奨化・ベストプラクティスの変更が行われます。リリースノートを追跡しないと:

- 強力な新機能（skills形式、prompt型フック、エージェント定義）を見逃す
- 将来のバージョンで壊れる可能性のある非推奨パターンを使い続ける
- トークンの無駄遣いや不要な権限プロンプトが発生する最適でない設定で運用する

## 機能

- Claude Codeリリースノートを**GitHub APIから取得・パース**（キャッシュ対応、レート制限準拠）
- セットアップを**スキャン** — CLAUDE.md、コマンド、エージェント、スキル、フック、設定、MCP設定
- リリースノートと設定を**照合**してギャップを発見
- Quick Wins・機能採用・非推奨警告・設定改善を含む**優先度付きレポート**を生成
- Before/Afterプレビュー付きで**修正を提案**（ユーザー確認後に適用）
- **英語・日本語対応**（1ファイル追加で言語拡張可能）

## claude-token-optimizer との関係

このプラグインは [claude-token-optimizer](https://github.com/ryoichi-u/claude-token-optimizer) を**補完**します:

| ツール | フォーカス |
|--------|-----------|
| **claude-token-optimizer** | トークン消費の分析・削減（静的コンテキスト、ランタイム注入） |
| **claude-upgrade-advisor** | リリースノート駆動の改善提案（機能採用、非推奨対応、モダナイズ） |

両者は連携して動作します — アドバイザーは必要に応じてオプティマイザーのコマンドを参照します。

## クイックスタート

### プラグインインストール（推奨）

```bash
# Claude Codeマーケットプレイスから
/plugin install claude-upgrade-advisor
```

### 手動インストール

```bash
git clone https://github.com/ryoichi-u/claude-upgrade-advisor.git
cd claude-upgrade-advisor
```

Claude Codeでプラグインが配置されたプロジェクトを開くか、プラグインパスに追加してください。

## コマンド

### `/upgrade-advisor` — フル分析

メインコマンド。リリースノートを取得し、セットアップをスキャンして包括的な改善レポートを生成します。

```
/upgrade-advisor                        # フル分析（デフォルト上位15件）
/upgrade-advisor --scope quick          # 上位5件のみ
/upgrade-advisor --scope full           # 全推奨事項
/upgrade-advisor --since 1.0.20         # v1.0.20以降のリリースのみ
/upgrade-advisor --lang en              # 英語出力を強制
/upgrade-advisor --force                # キャッシュを強制更新
```

**出力内容:**
- Quick Wins（低工数・高効果）
- 採用可能な新機能
- 非推奨パターンと移行パス
- 設定改善提案
- Before/Afterコード例

### `/cc-whatsnew` — リリースノートサマリー

最近のClaude Codeリリースの軽量ビュー。セットアップ分析なし。

```
/cc-whatsnew                    # 直近5件
/cc-whatsnew 10                 # 直近10件
/cc-whatsnew --since 1.0.25     # v1.0.25以降
```

### `/cc-check-deprecations` — 非推奨スキャナー

非推奨パターンに特化したスキャン。フル分析より高速。

```
/cc-check-deprecations          # スキャンしてレポート
/cc-check-deprecations --fix    # スキャンして修正を提案
```

## 自動発火スキル

以下の場合に自動的にアクティベートする**Model-invokedスキル**を含みます:

- Claude Codeのアップデートや新機能について質問した時
- 「もっと良い設定方法はある？」と聞いた時
- 通常の作業中に古いパターンを使用していることを検出した時

軽量な文脈依存の提案を行い、フル分析は実行しません。

## 設定

### キャッシュ

リリースノートは `~/.claude/cache/upgrade-advisor/` にキャッシュされ、24時間有効です。SessionStartフックがキャッシュ鮮度をチェックし（ネットワーク不使用）、7日以上古い場合に通知します。

キャッシュの手動管理:
```bash
bash scripts/cache-manager.sh status       # キャッシュ状態を表示
bash scripts/cache-manager.sh invalidate   # キャッシュをクリア
bash scripts/cache-manager.sh age          # キャッシュ経過時間を表示
```

### 言語

CLAUDE.mdの内容やシステムロケールから自動検出します。`--lang` で上書き:
- `--lang en` — 英語
- `--lang ja` — 日本語
- `--lang auto` — 自動検出（デフォルト）

### 言語の追加

`skills/upgrade-advisor-command/references/i18n/<code>.md` を `en.md` や `ja.md` のフォーマットに従って作成するだけです。`--lang <code>` で自動的に利用されます。

## 仕組み

```
ユーザーが /upgrade-advisor を実行
         │
         ▼
[言語検出] ──→ i18nテンプレート読み込み
         │
         ▼
[リリースノート取得] ──→ gh API → キャッシュ（24時間）
         │
         ▼
[バージョン検出] ──→ claude --version
         │
         ▼
[セットアップスキャン] ──→ CLAUDE.md, commands, agents, skills, hooks, settings, .mcp.json
         │
         ▼
[照合分析] ──→ リリース × 機能カタログ × 分析パターン × ユーザーファイル
         │
         ▼
[レポート生成] ──→ 優先度付き推奨事項 + Before/After
         │
         ▼
[アクション提案] ──→ 選択した修正を確認後に適用
```

## 要件

- **Claude Code** — 任意の最近のバージョン
- **gh** CLI（推奨） — GitHub APIアクセス用。`curl` + `GITHUB_TOKEN` 環境変数にフォールバック
- **python3** — スクリプトでのJSONパース用

## プラグイン構成

```
claude-upgrade-advisor/
├── .claude-plugin/plugin.json       # プラグインマニフェスト
├── skills/
│   ├── upgrade-advisor/             # Model-invoked 自動発火スキル
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── feature-catalog.md   # バージョン-機能マッピング
│   │       └── analysis-patterns.md # 検出ヒューリスティック
│   └── upgrade-advisor-command/     # /upgrade-advisor コマンド
│       ├── SKILL.md
│       └── references/
│           ├── i18n/en.md           # 英語ラベル
│           ├── i18n/ja.md           # 日本語ラベル
│           ├── analysis-rules.md    # 照合ルール
│           └── output-format.md     # レポート構造仕様
├── commands/
│   ├── cc-whatsnew.md               # /cc-whatsnew
│   └── cc-check-deprecations.md    # /cc-check-deprecations
├── hooks/hooks.json                 # SessionStart キャッシュチェック
└── scripts/
    ├── fetch-releases.sh            # GitHubリリース取得
    ├── cache-manager.sh             # キャッシュ管理
    └── parse-changelog.sh           # CHANGELOG.mdパーサー（フォールバック）
```

## コントリビュート

コントリビューション歓迎です！ 主な領域:

- **フィーチャーカタログ更新** — `feature-catalog.md` に新しいClaude Code機能を追加
- **分析パターン** — `analysis-patterns.md` に検出ヒューリスティックを追加
- **新言語** — `references/i18n/` にi18nテンプレートを追加
- **バグ修正** — Issueの報告やPRの送信

## ライセンス

MIT
