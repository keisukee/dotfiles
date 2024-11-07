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
