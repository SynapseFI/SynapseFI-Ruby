require 'test_helper'

class PhysicalDocumentTest < Minitest::Test
  def setup
    @base_document = SynapsePayRest::BaseDocument.create(test_base_document_args)
  end

  def test_create_with_value
    file = fixture_path('id.png')
    byte_stream = open(file).read
    base64 = Base64.encode64(byte_stream)
    mime_padding = 'data:image/png;base64,'
    padded = mime_padding + base64
    doc = SynapsePayRest::PhysicalDocument.create(type: 'GOVT_ID', value: padded)
    base_doc = @base_document.add_physical_documents(doc)
    refute_empty base_doc.physical_documents
  end

  def test_create_with_url
    url = 'https://cdn.synapsepay.com/static_assets/logo@2x.png'
    doc = SynapsePayRest::PhysicalDocument.create(type: 'GOVT_ID', url: url)
    base_doc = @base_document.add_physical_documents(doc)
    refute_empty base_doc.physical_documents
  end

  def test_create_with_url_and_query_params
    url = 'https://cdn.synapsepay.com/static_assets/logo@2x.png?testinh=1234'
    doc = SynapsePayRest::PhysicalDocument.create(type: 'GOVT_ID', url: url)
    base_doc = @base_document.add_physical_documents(doc)
    refute_empty base_doc.physical_documents
  end

  def test_create_with_file_path
    file_path = File.join(File.dirname(__FILE__), '../fixtures/test.png')
    doc = SynapsePayRest::PhysicalDocument.create(type: 'GOVT_ID', file_path: file_path)
    base_doc = @base_document.add_physical_documents(doc)
    refute_empty base_doc.physical_documents
  end

  def test_create_with_byte_stream
    file = fixture_path('id.png')
    byte_stream = open(file) { |f| f.read }
    doc = SynapsePayRest::PhysicalDocument.create(type: 'GOVT_ID', byte_stream: byte_stream, mime_type: 'image/png')
    base_doc = @base_document.add_physical_documents(doc)
    refute_empty base_doc.physical_documents
  end
end
