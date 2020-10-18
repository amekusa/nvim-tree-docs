(require-macros "fnl.nvim-tree-docs.macros")

(doc-spec
  {:spec jsdoc
   :lang javascript
   :config {:include_types true
            :empty_line_after_description true
            :author ""
            :tags {:function {:param true
                              :returns true
                              :export true}
                   :variable {:type true
                              :export true}
                   :class {:class true
                           :export true
                           :extends true}
                   :member {:memberOf true
                            :type true}
                   :method {:memberOf true
                            :param true
                            :returns true}}
            :processors {}}})

; (local tag-processor (require "nvim-tree-docs.tag-processor"))
; (local tag-processors
  ; {:param #(when $.parameters
  ;            (let [result []]
  ;              (each [param ($.iter $.parameters)]
  ;                (let [param-name (%> get-param-name $ param.entry)
  ;                      type-str (%> get-marked-type $ " ")
  ;                      name (%= name param.entry)]
  ;                  (table.insert
  ;                    result
  ;                    (.. " * @param " param-name type-str "- The " name))))))
;    :returns #(when $.returns
;                (let [type-str (%> get-marked-type $ " ")]
;                  (.. " * @returns" type-str  "The result")))
;    :type #(when $.type
;             (let [type-str (%> get-marked-type $ " ")]
;               (.. " * @type" type-str)))
;    :description #(.. " * " $.name " description")
;    :__default #(.. " * @" $2)})

(processor returns
  when #($.returns)
  build #(let [type-str (%> get-marked-type $ " ")]
           (.. " * @returns" type-str  "The result")))

(processor description
  configurable false
  build #(.. " * " $.name " description"))

(processor type
  when #($.type)
  build #(let [type-str (%> get-marked-type $ " ")]
           (.. " * @type" type-str)))

(processor param
  when #(and $.parameters
             (not ($.is-empty $.parameters)))
  build #(let [result []]
           (each [param ($.iter $.parameters)]
             (let [param-name (%> get-param-name $ param.entry)
                   type-str (%> get-marked-type $ " ")
                   name (%= name param.entry)]
               (table.insert
                 result
                 (.. " * @param " param-name type-str "- The " name))))))

(processor
  build #(.. " * @" $2))

; (util get-param-name [$ param]
;   (if param.default_value
;     (string.format "%s=%s"
;                    ($.get-text param.name)
;                    ($.get-text param.default_value))
;     ($.get-text param.name)))

; (util get-marked-type [$ not-found?]
;   (if (%conf $ include_types)
;     [" {" (%^ "any") "} "]
;     (or not-found? "")))

; (template function
;   "/**"
;   (%- description)
;   (%-%)
;   (%- param)
;   (%- returns)
;   " */"
;   (%content))

; (template function
;   "/**"
;   [" * " (%^ [(%= name) " description"])]
;   (%when (%conf $ empty_line_after_description) " *")
;   (%when $.export " * @export")
;   (%> get-parameter-lines $ $.parameters)
;   (%when $.return_statement (%> get-return-line $))
;   " */"
;   (%content))

; (template variable
;   "/**"
;   [" * " (%= name) " Description"]
;   (%when $.export " * @export")
;   (%when (%conf $ include_types) [" * @type" (%> get-marked-type $)])
;   " */"
;   (%content))

; (template method
;   "/**"
;   [" * " (%^ (%= name))]
;   (%when (%conf $ empty_line_after_description) " *")
;   (%when $.class [" * @memberOf " (%= class)])
;   (%> get-parameter-lines $ $.parameters)
;   (%when $.return_statement (%> get-return-line))
;   " */"
;   (%content))

; (template class
;   "/**"
;   [" * The " (%= name) " class."]
;   [" * @class " (%= name)]
;   (%when $.export " * @export")
;   (%each [extention ($.iter $.extentions)]
;      [" * @extends" (%= name extention.entry)])
;   " */"
;   (%content))

; (template member
;   "/**"
;   " * Description"
;   (%when $.class [ " * @memberOf " (%= class)])
;   (%when (%conf $ include_types) [" * @type" (%> get-marked-type $)])
;   " */"
;   (%content))
