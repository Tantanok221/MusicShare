# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(label:, variant: :primary, attr: {}, tag: :button)
    @label = label
    @variant = variant.to_sym
    @tag = tag.to_sym
    @attr = attr
  end

  def classes
    [ base_classes, variant_classes[@variant] ].join(" ")
  end

  def html_attributes
    existing = @attr[:class]
    merged_class = [ classes, existing ].compact.join(" ")
    @attr.merge(class: merged_class)
  end


  def base_classes
    "py-2 px-4 rounded-md text-sm font-medium font-sans text-center cursor-pointer"
  end

  def variant_classes
    {
      primary: "bg-primary  text-primary-foreground",
      secondary: "bg-secondary text-secondary-foreground",
    }
  end
end
