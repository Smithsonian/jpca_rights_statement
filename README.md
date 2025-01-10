# jpca_rights_statement
An ArchivesSpace plugin to support JPCA-style EAD exports.

_Rights Statements_

- Within `<archdesc>`, exports `<userestrict>` holding a `<head>`, `<note>`, and `<list><item><date/></item></list>` matching a resource-level rights statement.  Unpublished notes will be exported with an audience of "internal."  Rights statements are not exported by ASpace by default.
- Within `<c>`, exports `<userestrict>` holding a `<head>`, `<note>`, and `<list><item><date/></item></list>` matching an archival object-level rights statement.  Unpublished notes will be exported with an audience of "internal."  Rights statements are not exported by ASpace by default.

| Description                                                | ASpace Default (simplified example) | JPCA Override (simplified example)                                      |
| ---------------------------------------------------------- |------------------------------------ | ----------------------------------------------------------------------- |
| Resource-level rights statement with a published note.     | not exported                        | `<userestrict id="aspace_[identifier]" type="[rights_type]"><head>Rights Statement</head><note type="[note_type]"><p>[note_content]</p></note><list><item><date normal="[start_date]" type="start" /></item></list></userestrict>`                    |
| Component-level rights statement with a published note.    | not exported                        | `<userestrict id="aspace_[identifier]" type="[rights_type]"><head>Rights Statement</head><note type="[note_type]"><p>[note_content]</p></note><list><item><date normal="[start_date]" type="start" /></item></list></userestrict>`                    |
| Resource-level rights statement with an unpublished note.  | not exported                        | `<userestrict id="aspace_[identifier]" type="[rights_type]"><head>Rights Statement</head><note audience="internal" type="[note_type]"><p>[note_content]</p></note><list><item><date normal="[start_date]" type="start" /></item></list></userestrict>` |
| Component-level rights statement with an unpublished note. | not exported                        | `<userestrict id="aspace_[identifier]" type="[rights_type]"><head>Rights Statement</head><note audience="internal" type="[note_type]"><p>[note_content]</p></note><list><item><date normal="[start_date]" type="start" /></item></list></userestrict>` |

## Tests

Run the backend tests via: 

```
./build/run backend:test -Dspec="../../plugins/jpca_rights_statement"
```
