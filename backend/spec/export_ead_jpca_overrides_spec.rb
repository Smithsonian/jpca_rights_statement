# encoding: utf-8
require 'nokogiri'
require 'spec_helper'
require_relative '../../../../backend/spec/export_spec_helper'

# Used to check that the fields EAD needs resolved are being resolved by the indexer.
require_relative '../../../../indexer/app/lib/indexer_common_config'

describe 'JPCA EAD export mappings' do

  #######################################################################
  # FIXTURES
  #######################################################################

  def load_export_fixtures
    @published_note = build(:json_note_rights_statement, publish: true)
    @unpublished_note = build(:json_note_rights_statement, publish: false)
    other_opts = { rights_type: 'other', other_rights_basis: 'policy', start_date: generate(:yyyy_mm_dd) }

    resource = create(:json_resource,
                      :publish => true,
                      :rights_statements => [build(:json_rights_statement,
                                                   notes: [@published_note,
                                                           @unpublished_note]),
                                             build(:json_rights_statement, other_opts)]
                      )

    @resource = JSONModel(:resource).find(resource.id)

    @archival_object = create(:json_archival_object,
                              :resource => {:ref => @resource.uri},
                              :publish => true,
                              :rights_statements => [build(:json_rights_statement,
                                                           notes: [@published_note,
                                                                   @unpublished_note]),
                                                     build(:json_rights_statement, other_opts)]
                              )
  end

  def doc_unpublished
    Nokogiri::XML::Document.parse(@doc_unpublished.to_xml).remove_namespaces!
  end

  before(:all) do
    as_test_user('admin') do
      RSpec::Mocks.with_temporary_scope do
        # EAD export normally tries the search index first, but for the tests we'll
        # skip that since Solr isn't running.
        allow(Search).to receive(:records_for_uris) do |*|
          {'results' => []}
        end

        as_test_user("admin", true) do
          load_export_fixtures
          @doc_unpublished = get_xml("/repositories/#{$repo_id}/resource_descriptions/#{@resource.id}.xml?include_unpublished=true&include_daos=true")

          raise Sequel::Rollback
        end
      end
      expect(@doc_unpublished.errors.length).to eq(0)

      # if the word Nokogiri appears in the XML file, we'll assume something
      # has gone wrong
      expect(@doc_unpublished.to_xml).not_to include("Nokogiri")
      expect(@doc_unpublished.to_xml).not_to include("#&amp;")
    end
  end

  describe 'Within <archdesc>' do
    context 'when including unpublished' do
      let(:doc) { doc_unpublished }

      it 'exports rights_statements to <userestrict>' do
        expect(doc.at_xpath("/ead/archdesc/userestrict/@id").content).
          to match(@resource.rights_statements.first['identifier'])
        expect(doc.at_xpath("/ead/archdesc/userestrict/@type").content).
          to match(@resource.rights_statements.first['rights_type'])
        expect(doc.at_xpath("/ead/archdesc/userestrict/head").content).
          to match('Rights Statement')
        expect(doc.at_xpath("/ead/archdesc/userestrict/list/item/date/@type").content).
          to eq('start')
        expect(doc.at_xpath("/ead/archdesc/userestrict/list/item/date/@normal").content).
          to match(@resource.rights_statements.first['start_date'])
      end

      it 'includes published and unpublished notes' do
        expect(doc.xpath("/ead/archdesc/userestrict/note").count).to eq(2)
      end

      describe 'the unpublished note' do
        let(:note) { doc.at_xpath("/ead/archdesc/userestrict/note[@audience='internal']") }

        it 'has an audience of internal' do
          expect(note.at_xpath("@audience").content).to eq('internal')
        end

        it 'exports correctly' do
          expect(note.content).to match(@unpublished_note.content.join(''))
          expect(note.at_xpath("@type").content).to match(@unpublished_note.type)
        end
      end

      describe 'the published note' do
        let(:note) { doc.at_xpath("/ead/archdesc/userestrict/note[not(@audience='internal')]") }

        it 'has no audience attribute' do
          expect(note.at_xpath("@audience")).to be(nil)
        end

        it 'exports correctly' do
          expect(note.content).to match(@published_note.content.join(''))
          expect(note.at_xpath("@type").content).to match(@published_note.type)
        end
      end

      it 'exports other rights basis to altrender' do
        expect(doc.at_xpath("/ead/archdesc/userestrict[@type='other']").attributes).
          to include('altrender')
        expect(doc.at_xpath("/ead/archdesc/userestrict[@altrender]/@altrender").content).
          to match('policy')
      end

      it 'does not export altrender attribute for non-other type rights statements' do
        expect(doc.at_xpath("/ead/archdesc/userestrict[@type='copyright']").attributes).
          not_to include('altrender')
      end
    end
  end

  describe 'Within <c>' do
    context 'when including unpublished' do
      let(:doc) { doc_unpublished }

      it 'exports rights_statements to <userestrict>' do
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict/@id").content).
          to match(@archival_object.rights_statements.first['identifier'])
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict/@type").content).
          to match(@archival_object.rights_statements.first['rights_type'])
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict/head").content).
          to match('Rights Statement')
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict/list/item/date/@type").content).
          to eq('start')
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict/list/item/date/@normal").content).
          to match(@archival_object.rights_statements.first['start_date'])
      end

      it 'includes published and unpublished notes' do
        expect(doc.xpath("/ead/archdesc/dsc/c/userestrict/note").count).to eq(2)
      end

      describe 'the unpublished note' do
        let(:note) { doc.at_xpath("/ead/archdesc/dsc/c/userestrict/note[@audience='internal']") }

        it 'has an audience of internal' do
          expect(note.at_xpath("@audience").content).to eq('internal')
        end

        it 'exports correctly' do
          expect(note.content).to match(@unpublished_note.content.join(''))
          expect(note.at_xpath("@type").content).to match(@unpublished_note.type)
        end
      end

      describe 'the published note' do
        let(:note) { doc.at_xpath("/ead/archdesc/dsc/c/userestrict/note[not(@audience='internal')]") }

        it 'has no audience attribute' do
          expect(note.at_xpath("@audience")).to be(nil)
        end

        it 'exports correctly' do
          expect(note.content).to match(@published_note.content.join(''))
          expect(note.at_xpath("@type").content).to match(@published_note.type)
        end
      end

      it 'exports other rights basis to altrender' do
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict[@type='other']").attributes).
          to include('altrender')
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict[@altrender]/@altrender").content).
          to match('policy')
      end

      it 'does not export altrender attribute for non-other type rights statements' do
        expect(doc.at_xpath("/ead/archdesc/dsc/c/userestrict[@type='copyright']").attributes).
          not_to include('altrender')
      end
    end
  end
end
