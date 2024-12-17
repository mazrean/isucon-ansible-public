# メモ

## MySQL
### 他鯖からのアクセス許可
```
CREATE USER "{{user}}"@"{{private ip}}" IDENTIFIED BY "{{password}}";
GRANT ALL PRIVILEGES ON *.* TO "{{user}}"@"{{private ip}}";
```

### gzip圧縮
```
find ./* | xargs -I {} sh -c 'gzip -9 -v -N -c {} > {}.gz'
```

### Unix Socket(nginx)
```
upstream app {
    keepalive 1024;
    server unix:/tmp/isucari.sock;
}
```

### ssh鍵の設定
```
wget -O - https://github.com/mazrean.keys >> ~/.ssh/authorized_keys
```
