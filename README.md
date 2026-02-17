# setup
下記のスクリプトを順に実行
`git clone https://github.com/keisukee/dotfiles.git`
`cd dotfiles`
`sh setup.sh`

## scripts
- git_commit_message_generator.py
  - ステージングされたファイルの差分を取得し、ChatGPTを使用してコミットメッセージを生成するスクリプト
  - 引数に言語を指定可能
    - `python git_commit_message_generator.py ja`
    - `python git_commit_message_generator.py en`

## Karabiner-Elements
設定を反映するには、`.config/karabiner` を `~/.config/karabiner` にコピーする。

```bash
cp -r .config/karabiner ~/.config/karabiner
```

## Tips

### macOS: Google IME の入力ソース切り替えインジケーターを非表示にする
入力ソース切り替え時にカーソル付近に表示される「あ」「A」のインジケーターを消す方法。

```bash
# 非表示にする
defaults write NSGlobalDomain NSShowInputModeIndicator -bool false

# 元に戻す場合
defaults delete NSGlobalDomain NSShowInputModeIndicator
```

変更後、ログアウト→ログインまたは再起動が必要。
