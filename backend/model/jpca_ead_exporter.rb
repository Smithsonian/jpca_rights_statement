# encoding: utf-8
require 'nokogiri'
require 'securerandom'

class EADSerializer < ASpaceExport::Serializer
  serializer_for :ead

  def serialize_rights(data, xml, fragments)
    data.rights_statements.each do |rts_stmt|
      xml.userestrict({ id: "aspace_#{rts_stmt['identifier']}", type: rts_stmt['rights_type'] }) {
        xml.head('Rights Statement')

        rts_stmt['notes'].each do |note|

          atts = {}
          atts['type'] = note['type']
          atts['audience'] = 'internal' if note['publish'] === false

          xml.note(atts) {
            xml.p {
              note['content'].each do |c|
                sanitize_mixed_content(c, xml, fragments)
              end
            }
          }
        end

        xml.list {
          xml.item {
            xml.date({ type: 'start', normal: rts_stmt['start_date'] }) if rts_stmt['start_date']
            xml.date({ type: 'end', normal: rts_stmt['end_date'] }) if rts_stmt['end_date']
          }
        }
      }
    end
  end

end
