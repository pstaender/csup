# Cloud Storage Uploader

Uploads (large) data by pipe to Google Drive.

Very basic and it's only working with Google Drive.

At the moment you can use only `stdin` as source (there is **no** feature with file sending like `csup -f file_to_send.txt` implemented, yet).

## Install

```sh
  $ git clone git@github.com:pstaender/csup.git csup
  $ cd csup && npm install .
```

If you want to use it on globally on commandline (recommend):

```sh
  $ chmod +x lib/csup
  $ (sudo) ln -s $(pwd)/bin/csup /usr/local/bin/csup
```

Take a quick look at **Configuration and Authentication** (below) before using it.

## Usage

Process (large) data and pipe them to cloud storage:

```sh
  $ do_something | do_some_other_stuff | … | csup -n output.txt
```

Some real life examples:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -n "log.gz"
  * 0B_aNw316e3FwdXEwXEdCMnlVaW8 -> log.gz (1.2mb)
```
If you prefer more verbosity:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -vn "log.gz"
  { id: '0B_aNw316e3FwdXEwXEdCMnlVaW8',
  filename: 'log.gz',
  mimeType: 'application/x-gzip; charset=UTF-8',
  downloadUrl: 'https://doc-0o-9s-docs.googleusercontent.com/docs/securesc/…?h=…&e=download&gd=true',
  createdDate: '2014-04-14T12:36:40.200Z',
  modifiedDate: '2014-04-14T12:36:40.021Z',
  md5Checksum: '92e4e5e7834dc754186f07c8e868dbf9',
  fileSize: 1234567,
  originalFilename: 'Untitled',
  ownerNames: [ 'OwnerName' ] }
  * 0B_aNw316e3FwdXEwXEdCMnlVaW8 -> log.gz (1.2mb)
```

Sending a large videofile could be

```sh
  $ cat video.mkv | csup
  * 0B_eNw266a3FwRVZjaGNPVnVTbzQ-> file_1397434048983 (320.2mb)
```

or by giving a filename (recommend):

```sh
  $ cat james_bond.mkv | csup -n JamesBond.mkv
  * 0B_eNw266a3FwRVZjaGNPVnVTbzQ -> JamesBond.mkv (320.2mb)
```

Force a specific filetype:

```sh
  $ cat README.md | csup -n README.md -t text/troff
```

Maybe the most valuable tool(s): tar and compress a folder, encrypt it and send it directly to your Google Drive: 

```sh
  $ tar cz folder_to_encrypt | openssl enc -aes-256-cbc -e -pass pass:mypass | csup -n backup_$(date +"%Y-%m-%d_%H:%M:%S_%Z").tar.gz.enc
```

For the rest of us who is not familiar with encrypting and decryption After downloading the file from Google Drive, ecrypting and deflating would be:

```sh
  $ openssl enc -d -aes-256-cbc -in out.tar.gz.enc -pass pass:mypass | out.tar.gz | tar xz
```

## Configuration and Authentication

Edit the config file and replace with your credentials:

```sh
  $ vim ~/.csup
```

```yaml
clientID: ***.apps.googleusercontent.com
clientSecret: ***
redirectURL: http://localhost
```

Now we need to request the accesstoken from google (will be stored by csub in `~/.csub` by default after entering on prompt):

```sh
  $ csup auth
  Visit the url:
  https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.file&response_type=code&client_id=***vs.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost
  Enter the code here: 
```

Visit the given url and enter the code which is given in the browser url after granting access (e.g. http://localhost/?code=**4/6Lu5yZys3A4fFmVDcEF-hSKxrHs-.EsFadx5GgeweOl05ti2ZT3YjGrG6igI**).

## Further docs

  * https://code.google.com/apis/console/
  * https://developers.google.com/oauthplayground/

## License

MIT License 
