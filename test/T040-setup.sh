#!/usr/bin/env bash

test_description='"notmuch setup"'
. $(dirname "$0")/test-lib.sh || exit 1

test_begin_subtest "Notmuch new without a config suggests notmuch setup"
output=$(notmuch --config=new-notmuch-config new 2>&1)
test_expect_equal "$output" "\
Error: cannot load config file.
Try running 'notmuch setup' to create a configuration."

test_begin_subtest "Create a new config interactively"
notmuch --config=new-notmuch-config > log.${test_count} <<EOF
Test Suite
test.suite@example.com
another.suite@example.com

/path/to/maildir
foo bar
baz
EOF

cat <<EOF > EXPECTED
built_with.compact=something
built_with.field_processor=something
built_with.retry_lock=something
database.mail_root=/path/to/maildir
database.path=/path/to/maildir
maildir.synchronize_flags=true
new.ignore=
new.tags=foo;bar;
search.exclude_tags=baz;
user.name=Test Suite
user.other_email=another.suite@example.com;
user.primary_email=test.suite@example.com
EOF

notmuch --config=new-notmuch-config config list | notmuch_built_with_sanitize > OUTPUT

test_expect_equal_file EXPECTED OUTPUT



test_begin_subtest "notmuch with a config but without a database suggests notmuch new"
notmuch 2>&1 | notmuch_dir_sanitize > OUTPUT
cat <<EOF > EXPECTED
Notmuch is configured, but no database was found.
You probably want to run "notmuch new" now to create a database.

Note that the first run of "notmuch new" can take a very long time
and that the resulting database will use roughly the same amount of
storage space as the email being indexed.

EOF
test_expect_equal_file EXPECTED OUTPUT

test_done
