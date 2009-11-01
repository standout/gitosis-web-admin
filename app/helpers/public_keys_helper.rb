module PublicKeysHelper

  def public_keys_for_select
    keys = PublicKey.all - @repository.public_keys
    options_for_select(keys.collect { |pk|
      [ "#{h(pk.short_description(40))} - #{h(pk.email)}", pk.id ]
    }, { :include_blank => true })
  end

end
