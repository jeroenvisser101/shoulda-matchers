module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_confirmation_of` matcher tests usage of the
      # `validates_confirmation_of` validation.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :email
      #
      #       validates_confirmation_of :email
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it { should validate_confirmation_of(:email) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_confirmation_of(:email)
      #     end
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :password
      #
      #       validates_confirmation_of :password, on: :create
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it { should validate_confirmation_of(:password).on(:create) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_confirmation_of(:password).on(:create)
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :password
      #
      #       validates_confirmation_of :password,
      #         message: 'Please re-enter your password'
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it do
      #         should validate_confirmation_of(:password).
      #           with_message('Please re-enter your password')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_confirmation_of(:password).
      #         with_message('Please re-enter your password')
      #     end
      #
      # @return [ValidateConfirmationOfMatcher]
      #
      def validate_confirmation_of(attr)
        ValidateConfirmationOfMatcher.new(attr)
      end

      # @private
      class ValidateConfirmationOfMatcher < ValidationMatcher
        include Helpers

        attr_reader :attribute, :confirmation_attribute

        def initialize(attribute)
          super
          @expected_message = :confirmation
          @confirmation_attribute = "#{attribute}_confirmation"
        end

        def simple_description
          "validate that :#{@confirmation_attribute} matches :#{@attribute}"
        end

        def matches?(subject)
          super(subject)

          disallows_different_value &&
            allows_same_value &&
            allows_missing_confirmation
        end

        private

        def disallows_different_value
          disallows_value_of('different value') do |matcher|
            qualify_matcher(matcher, 'some value')
          end
        end

        def allows_same_value
          allows_value_of('same value') do |matcher|
            qualify_matcher(matcher, 'same value')
          end
        end

        def allows_missing_confirmation
          allows_value_of('any value') do |matcher|
            qualify_matcher(matcher, nil)
          end
        end

        def qualify_matcher(matcher, confirmation_attribute_value)
          matcher.values_to_preset = {
            confirmation_attribute => confirmation_attribute_value
          }
          matcher.with_message(
            @expected_message,
            against: confirmation_attribute,
            values: { attribute: attribute }
          )
        end

        def set_confirmation(value)
          @last_value_set_on_confirmation_attribute = value

          AttributeSetter.set(
            matcher_name: 'confirmation',
            object: @subject,
            attribute_name: confirmation_attribute,
            value: value
          )
        end
      end
    end
  end
end
