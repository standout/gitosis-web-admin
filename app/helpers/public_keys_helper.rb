module PublicKeysHelper

  def public_keys_for_select
    keys = PublicKey.all - @repository.public_keys
    options_for_select(keys.collect { |pk|
      [ h(pk.label), pk.id ]
    }, { :include_blank => true })
  end

end
