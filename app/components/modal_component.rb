# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  renders_one :trigger
  renders_one :body

  def initialize(id:, title:, size: :medium)
    @id = id
    @title = title
    @size = size
  end

  private

  def modal_max_width_class
    case @size
    when :small
      "max-w-sm"
    when :medium
      "max-w-md"
    when :large
      "max-w-lg"
    when :xl
      "max-w-xl"
    when :full
      "max-w-[90%]"
    else
      "max-w-md"
    end
  end
end
