# encoding: utf-8
require 'nokogiri'
require 'securerandom'

class EADSerializer < ASpaceExport::Serializer
  serializer_for :ead

  def serialize_rights(data, xml, fragments)
    data.rights_statements.each do |rts_stmt|

      rts_atts = {}
      rts_atts['id'] = rts_stmt['identifier']
      rts_atts['type'] = rts_stmt['rights_type']
      rts_atts['altrender'] = rts_stmt['other_rights_basis'] unless rts_stmt.dig('other_rights_basis').nil?

      xml.userestrict(rts_atts) {
        xml.head('Rights Statement')

        rts_stmt['notes'].each do |note|

          note_atts = {}
          note_atts['type'] = note['type']
          note_atts['audience'] = 'internal' if note['publish'] === false

          xml.note(note_atts) {
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
