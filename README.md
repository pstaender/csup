# Cloud Storage Uploader

Uploads (large) data trough the pipe to Google Drive.

Very basic and it's only working with GDrive for now.

You can use `stdin` / pipe as source only. There won't be any feature to send a file by parameter in near future.

## Requirements

  * unix environment
  * nodejs (tested with v0.10.*)
  * [Google API access](https://developers.google.com/drive/web/enable-sdk) (free)

## Install

```sh
  $ (sudo) npm install -g csup
```

Take a quick look at **Configuration and Authentication** (below) before using it.

## Configuration and Authentication

```sh
  $ csup setup
```

## How to create a clientID and clientSecret

## Commands

```sh
  $ csup help

  Usage: csup (switch) (-option|--option)

  switches:
    auth        receives `accessToken` from Google API (interactive)
    setup       setups `clientID` + `clientSecret` (interactive)

  options:
    -h --help   displays help
    -n --name   filename for cloud storage    e.g. -n filename.txt
    -t --type   force a specific filetype     e.g. -t 'application/zip'
    -v -vv -vvv verbosity
```

## Examples

Process (large) data and pipe them to cloud storage and returns the `downloadUrl` if succeeded:

```sh
  $ do_something | do_some_other_stuff | … | csup -n output.txt
  https://doc-0s-9s-docs.googleusercontent.com/docs/securesc/dadasfd42pdda6fpf5nfads?h=1234&e=download&gd=true
```

Uploading a log file and zip it:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -n "log.gz"
  https://doc-0s-9s-docs.googleusercontent.com/docs/securesc/dadasfd42pdda6fpf5nfads?h=1234&e=download&gd=true
```

If you prefere more verbosity:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -v -n "log.gz"
  0B_aNw316e3FwdXEwXEdCMnlVaW8  log.gz  1.2mb
```

If you prefer more verbosity:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -vv -n "log.gz"
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
```

Sending a large videofile could be

```sh
  $ cat video.mkv | csup
```

With giving a filename (recommend):

```sh
  $ cat james_bond.mkv | csup -n JamesBond.mkv
```

Force a specific filetype:

```sh
  $ cat README.md | csup -n README.md -t text/troff
```

## Download the file

With url you can download the file:

```sh
  $ csup https://doc-0s-9s-docs.googleusercontent.com/docs/securesc/dadasfd42pdda6fpf5nfads?h=1234&e=download&gd=true > myfile.txt
```

Up- and download a file in one step:

```sh
  $ cat file.json | ./bin/csup -n file.json | xargs -0 -I url ./bin/csup url > downloaded_file.json
```

## Example#1: Upload tar/zipped and encrypted folders

Tar and compress a folder, encrypt it and send it directly to your Google Drive: 

```sh
  $ tar cz folder_to_encrypt | openssl enc -aes-256-cbc -e -pass pass:mypass | csup -n backup_$(date +"%Y-%m-%d_%H:%M:%S_%Z").tar.gz.enc
```

Encrypting and deflating would be:

```sh
  $ openssl enc -d -aes-256-cbc -in out.tar.gz.enc -pass pass:mypass | out.tar.gz | tar xz
```
## Example #2: Incremental backups with tar

I'll figure out an example the next weeks, so far take look at [http://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html](http://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html)

## Limitations

According to [Google Drive support](https://support.google.com/drive/answer/37603?hl=en) you are able to upload up to **1TB large files** if you own that much space.

## Further docs

  * https://developers.google.com/drive/web/quickstart/quickstart-js
  * https://code.google.com/apis/console/
  * https://developers.google.com/oauthplayground/

## License

MIT License 
