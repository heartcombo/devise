class Custom::RegistrationsController < Devise::RegistrationsController

  def create_block_called?
    @create_block_called == true
  end

  def update_block_called?
    @update_block_called == true
  end

  protected

    def after_sign_up_success(resource)
      @create_block_called = true
    end

    def after_sign_up_fails(resource)
      @create_block_called = false
    end

    def after_account_update_success(resource)
      @update_block_called = true
    end

    def after_account_update_fails(resource)
      @update_block_called = false
    end
end
