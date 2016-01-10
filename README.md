Nanami Storage Client
=====================

Minio(AWS S3互換API)をシュッと叩くクライアント

## 初期設定
```
$ bundle
$ touch .env
$ # write your key
$ cat .env
AWS_ACCESS_KEY=ACCESS_KEY
AWS_SECRET_KEY=SECRET_KEY
AWS_ENDPOINT=ENDPOINT
```

## 使い方
### バケットの作成
```
$ be ruby client.rb -c bucket-name
```

名前に`_`は使えないぽい．`-`は使えるぽい．

### バケットの削除
```
$ be ruby client.rb -r bucket-name
```

中にオブジェクトがあるバケットは削除できない．

### オブジェクトのアップロード
```
$ be ruby client.rb -p /path/to/file bucket-name
```

### オブジェクトのダウンロード
```
$ be ruby client.rb -p bucket-name/object-key /path/to/file
```

### バケット/オブジェクトのリスト
```
$ be ruby client.rb -l bucket-name
```

bucket-nameを指定するとバケット内のオブジェクトを列挙する．無指定でバケットのリストを列挙する．

### その他
`list`, `create_bucket`, `remove_bucket`オプションでbucket-nameを複数指定すると指定した全てのbucketに対してコマンドを実行する．
