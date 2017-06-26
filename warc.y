
%{
package warc

func setRecord(yylex interface{}, p *parseRecord) {
  yylex.(*Tokenizer).Record = p
}

func getParseRecord(yylex interface{}) *parseRecord {
  return yylex.(*Tokenizer).Record
}

func addRecord(yylex interface{}, p *parseRecord) {
  tkn := yylex.(*Tokenizer)
  r, err := p.Record()
  if err != nil {
    tkn.ForceEOF = true
    tkn.LastError = err.Error()
  }
  tkn.Records = append(yylex.(*Tokenizer).Records, r)
  tkn.Record = &parseRecord{}
}

func forceEOF(yylex interface{}) {
  yylex.(*Tokenizer).ForceEOF = true
}

%}

%union {
  empty       struct{}
  records     []Record
  parseRecord *parseRecord
  token       string
  bytes       []byte
  recordType  RecordType
}

%token LEX_ERROR
// Warc Record Types
%token <empty> WARCINFO RESPONSE RESOURCE REQUEST METADATA REVISIT CONVERSION CONTINUATION
// Defined Fields
%token <empty> WARC_RECORD_ID WARC_DATE CONTENT_LENGTH CONTENT_TYPE WARC_CONCURRENT_TO WARC_BLOCK_DIGEST WARC_PAYLOAD_DIGEST WARC_IP_ADDRESS WARC_REFERS_TO WARC_TARGET_URI WARC_TRUNCATED WARC_WARCINFO_ID WARC_FILENAME WARC_PROFILE WARC_IDENTIFIED_PAYLOAD_TYPE WARC_SEGMENT_ORIGIN_ID WARC_SEGMENT_NUMBER WARC_SEGMENT_TOTAL_LENGTH WARC_TYPE
%token <bytes> WARC_VERSION FIELD_KEY FIELD_VALUE BLOCK

%type <records> warc_records
%type <parseRecord> warc_record headers header
%type <recordType> warc_type

%start warc_records

%%

warc_records:
  warc_record
  {
    addRecord(yylex, $1)
  }
| warc_records warc_record
  {
    addRecord(yylex, $2)
    // setRecord(yylex, $2)
    //$$ = append($1, $2)
  }

warc_record:
  WARC_VERSION headers BLOCK
  {
    h := getParseRecord(yylex)
    h.Version = string($1)
    h.Content = $3
    $$ = h
  }

headers:
header
  {
    $$ = $1
  }
| headers header
{
  $$ = $2
}

header:
CONTENT_LENGTH FIELD_VALUE
  {
    // TODO - convert to number
    h := getParseRecord(yylex)
    h.ContentLength = string($2)
    $$ = h
  }
| CONTENT_TYPE FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.ContentType = string($2)
    $$ = h
  }
| WARC_BLOCK_DIGEST FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCBlockDigest = string($2)
    $$ = h
  }
| WARC_CONCURRENT_TO FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCConcurrentTo = string($2)
    $$ = h
  }
| WARC_DATE FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCDate = string($2)
    $$ = h
  }
| WARC_FILENAME FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCFilename = string($2)
    $$ = h
  }
| WARC_IDENTIFIED_PAYLOAD_TYPE FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCIdentifiedPayloadType = string($2)
    $$ = h
  }
| WARC_IP_ADDRESS FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCIPAddress = string($2)
    $$ = h
  }
| WARC_PAYLOAD_DIGEST FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCPayloadDigest = string($2)
    $$ = h
  }
| WARC_PROFILE FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCProfile = string($2)
    $$ = h
  }
| WARC_RECORD_ID FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCRecordId = string($2)
    $$ = h
  }
| WARC_REFERS_TO FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCRefersTo = string($2)
    $$ = h
  }
| WARC_SEGMENT_ORIGIN_ID FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCSegmentOriginID = string($2)
    $$ = h
  }
| WARC_SEGMENT_NUMBER FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCSegmentNumber = string($2)
    $$ = h
  }
| WARC_SEGMENT_TOTAL_LENGTH FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCSegmentTotalLength = string($2)
    $$ = h
  }
| WARC_TARGET_URI FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCTargetURI = string($2)
    $$ = h
  }
| WARC_TRUNCATED FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCTruncated = string($2)
    $$ = h
  }
| WARC_WARCINFO_ID FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.WARCWarcinfoID = string($2)
    $$ = h
  }
| WARC_TYPE warc_type
  {
    h := getParseRecord(yylex)
    h.WARCType = $2
    $$ = h
  }
| FIELD_KEY FIELD_VALUE
  {
    h := getParseRecord(yylex)
    h.CustomFields[string($1)] = string($2)
    $$ = h
  }

warc_type:
CONVERSION
  {
    $$ = RecordTypeConversion
  }
| CONTINUATION
  {
    $$ = RecordTypeContinuation
  }
| METADATA
  {
    $$ = RecordTypeMetadata
  }
| RESOURCE
  {
    $$ = RecordTypeResource
  }
| RESPONSE
  {
    $$ = RecordTypeResponse
  }
| REQUEST
  {
    $$ = RecordTypeRequest
  }
| REVISIT
  {
    $$ = RecordTypeRevisit
  }
| WARCINFO
  {
    $$ = RecordTypeWarcInfo
  }