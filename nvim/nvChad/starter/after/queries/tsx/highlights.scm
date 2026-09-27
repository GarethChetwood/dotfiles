;; extends

(enum_declaration
  name: (identifier) @type.enum)

(enum_body
  (property_identifier) @variable.member.enum)

(enum_assignment
  name: (property_identifier) @variable.member.enum)

(import_clause
  (identifier) @variable.import)

;; Recognize PascalCase.PascalCase as Enum.EnumMember when referred to later
((member_expression
  object: (identifier) @type.enum
  property: (property_identifier) @variable.member.enum)
 (#match? @type.enum "^[A-Z]")
 (#match? @variable.member.enum "^[A-Z]"))

((jsx_opening_element name: (member_expression object: (identifier) @tag.builtin property: (property_identifier) @tag))
 (#set! priority 105))

((jsx_closing_element name: (member_expression object: (identifier) @tag.builtin property: (property_identifier) @tag))
 (#set! priority 105))

((jsx_self_closing_element name: (member_expression object: (identifier) @tag.builtin property: (property_identifier) @tag))
 (#set! priority 105))
