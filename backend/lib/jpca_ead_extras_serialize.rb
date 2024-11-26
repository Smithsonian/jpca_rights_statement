class JPCAEADSerialize < EADSerializer

  def call(data, xml, fragments, context)
    if context == :archdesc
      if data.rights_statements
        serialize_rights(data, xml, fragments)
      end
    end
  end

end
