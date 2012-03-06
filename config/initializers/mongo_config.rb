Dictionary.ensure_index(:term)

Page.ensure_index(:docid)
Page.ensure_index(:url)

Posting.ensure_index(:docid)
Posting.ensure_index(:term)
