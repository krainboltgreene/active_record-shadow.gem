module Spec
  class Cart < ActiveRecord::Base; end
  class Item < ActiveRecord::Base; end
  class Consumer < ActiveRecord::Base; end
  class CartShadow < ActiveRecord::Shadow::Member; end
  class ItemShadow < ActiveRecord::Shadow::Member; end
  class ConsumerShadow < ActiveRecord::Shadow::Member; end
  class CartsShadow < ActiveRecord::Shadow::Collection; end
  class ItemsShadow < ActiveRecord::Shadow::Collection; end
  class ConsumersShadow < ActiveRecord::Shadow::Collection; end
end
