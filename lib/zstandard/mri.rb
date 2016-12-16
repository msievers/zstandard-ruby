require "ffi"

module Zstandard
  module MRI
    extend FFI::Library
    ffi_lib [FFI::CURRENT_PROCESS, "ruby"]

    attach_function :rb_str_resize, :rb_str_resize, [:pointer, :long], :pointer

    def self.sizeof(type)
      Class.new(FFI::Struct) do
        layout(member: type)
      end
      .size
    end

    VALUE = typedef :pointer, :VALUE

    class RBasic < FFI::Struct
      layout(
        flags: VALUE,
        klass: VALUE
      )
    end

    RSTRING_EMBED_LEN_MAX = ((sizeof(VALUE)*3) / sizeof(:char)) - 1

    class RString < FFI::Struct
      layout(
        basic: RBasic,
        as:    Class.new(FFI::Union) do
          layout(
            heap: Class.new(FFI::Struct) do
              layout(
                len: :long,
                ptr: :pointer,
                aux: Class.new(FFI::Union) do
                  layout(
                    capa:   :long,
                    shared: VALUE
                  )
                end
              )
            end,
            ary: [:char, RSTRING_EMBED_LEN_MAX]
          )
        end
      )
    end
  end
end 
