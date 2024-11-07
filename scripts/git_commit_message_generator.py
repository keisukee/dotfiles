import subprocess
import os
from openai import OpenAI
import sys
import argparse
from dotenv import load_dotenv

def get_staged_diff():
    """ステージングされたファイルの差分を取得"""
    try:
        # git diffコマンドを実行してステージング済みの変更を取得
        result = subprocess.run(['git', 'diff', '--cached'],
                              capture_output=True,
                              text=True,
                              check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Gitコマンドの実行中にエラーが発生しました: {e}")
        sys.exit(1)

def generate_commit_message(diff_content, language):
    """ChatGPTを使用してコミットメッセージを生成"""
    try:
        client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

        # プロンプトの作成
        if language == 'ja':
            prompt = f"以下のGit差分に基づいて、簡潔なコミットメッセージを生成してください。敬体ではなく常体で。コミットメッセージは以下の形式に従ってください：1行目: 変更の要約（50文字以内）、2行目: 空行、3行目以降: 詳細な説明（必要な場合）。変更点は'-'でポイントわけしてください。Git差分: {diff_content}"
            system_message = "あなたは優れたプログラマーで、Git差分を分析して適切なコミットメッセージを生成する専門家です。"
        else:
            prompt = f"Based on the following Git diff, generate a concise commit message. The commit message should follow this format: Line 1: Summary of changes (within 50 characters), Line 2: Blank line, Line 3 and beyond: Detailed description (if necessary). Use '-' to bullet point the changes. Git diff: {diff_content}"
            system_message = "You are an excellent programmer and an expert in analyzing Git diffs to generate appropriate commit messages."

        # ChatGPT APIを呼び出し
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_message},
                {"role": "user", "content": prompt}
            ]
        )

        commit_message = response.choices[0].message.content
        return f"{commit_message}\n(generated by gpt-4o)"

    except Exception as e:
        print(f"コミットメッセージの生成中にエラーが発生しました: {e}")
        sys.exit(1)

def main():
    # .envファイルから環境変数を読み込む
    load_dotenv()

    # コマンドライン引数の解析
    parser = argparse.ArgumentParser(description='Generate a commit message using OpenAI.')
    parser.add_argument('--lang', choices=['en', 'ja'], default='ja', help='Specify the language for the commit message: "en" for English, "ja" for Japanese.')
    args = parser.parse_args()

    # 環境変数のチェック
    if not os.environ.get("OPENAI_API_KEY"):
        print("OPENAI_API_KEYが設定されていません。")
        sys.exit(1)
    
    # Gitリポジトリであることを確認
    if not os.path.exists('.git'):
        print("このディレクトリはGitリポジトリではありません。")
        sys.exit(1)
    
    # ステージングされた変更があるか確認
    diff_content = get_staged_diff()
    if not diff_content:
        print("ステージングされた変更がありません。")
        sys.exit(1)

    # コミットメッセージを生成
    commit_message = generate_commit_message(diff_content, args.lang)
    if commit_message is None:
        print("コミットメッセージの生成に失敗しました。")
        sys.exit(1)

    # コミットメッセージをファイルに保存
    message_file = '.git/COMMIT_EDITMSG'
    with open(message_file, 'w') as f:
        f.write(commit_message)

    print("\n生成されたコミットメッセージ:")
    print("-" * 50)
    print(commit_message)
    print("-" * 50)

    # ユーザーに確認
    response = input("\nこのメッセージでコミットを作成しますか？ (y/n): ")
    if response.lower() == 'y':
        try:
            subprocess.run(['git', 'commit', '-F', message_file], check=True)
            print("コミットが正常に作成されました。")
        except subprocess.CalledProcessError as e:
            print(f"コミットの作成中にエラーが発生しました: {e}")
            sys.exit(1)
    else:
        print("コミットがキャンセルされました。")

if __name__ == "__main__":
    main()
