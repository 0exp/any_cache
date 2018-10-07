# frozen_string_literal: true

describe 'Patches interface' do
  describe 'patch activation' do
    it 'fails when the required patch does not exist' do
      random_nonexistent_patch_name = SecureRandom.hex(rand(1..4)).to_sym

      expect do
        AnyCache.enable_patch!(random_nonexistent_patch_name)
      end.to raise_error(AnyCache::NonexistentPatchError)
    end
  end
end
