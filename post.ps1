[string] $title = Read-host "post title"
powershell -Command "bundle exec jekyll post ${title}"