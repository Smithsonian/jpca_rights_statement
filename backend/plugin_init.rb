require_relative 'lib/jpca_ead_extras_serialize'

# Register our custom serialize steps.
EADSerializer.add_serialize_step(JPCAEADSerialize)
