import 'dart:async';
import 'dart:math';

import 'package:macros/macros.dart';

final _dartCore = Uri.parse('dart:core');
final _thisLibrary = Uri.parse('package:ffx/ffx.dart');
final _xLibrary = Uri.parse('package:ffx/src/x/x.dart');
final _fLibrary = Uri.parse('package:ffx/src/f/f.dart');
final _flutterWidget = Uri.parse('package:flutter/material.dart');

macro

class Fx implements FunctionDeclarationsMacro, ClassDeclarationsMacro {
  const Fx();

  ///来翻译函数转换到widget
  @override
  FutureOr<void> buildDeclarationsForFunction(FunctionDeclaration function,
      DeclarationBuilder builder) async {
    // print('function name  ${function.identifier.name}');

    String functionName = function.identifier.name;
    if (!functionName.startsWith('_')) {
      throw DiagnosticException(Diagnostic(
          DiagnosticMessage(
              'FX should only be used on private declarations',
              target: function.asDiagnosticTarget),
          Severity.error));
    }
    if (functionName.startsWith('__')) {
      throw DiagnosticException(Diagnostic(
          DiagnosticMessage(
              '__ to much',
              target: function.asDiagnosticTarget),
          Severity.error));
    }

    String fName = functionName
        .substring(1)
        .capitalize;

    final namedParameters = function.namedParameters;

    final allParameters = function.positionalParameters
        .followedBy(function.namedParameters);

    // namedParameters.forEach((e){
    //   e.code.defaultValue //有bug没有值
    //   print(_printParts([...e.code.parts,'     ',e.code]));
    // });

    // function.library;


    // ignore: deprecated_member_use
    final f = await builder.resolveIdentifier(_fLibrary, 'F');

    // ignore: deprecated_member_use
    final x = await builder.resolveIdentifier(_xLibrary, 'X');

    // ignore: deprecated_member_use
    final fx = await builder.resolveIdentifier(_fLibrary, 'FWidget');
    // ignore: deprecated_member_use
    final modifier = await builder.resolveIdentifier(_fLibrary, 'Modifier');
    // ignore: deprecated_member_use
    final modifior = await builder.resolveIdentifier(_fLibrary, 'Modifior');
    // ignore: deprecated_member_use
    final fxKey = await builder.resolveIdentifier(_fLibrary, 'FXKey');

    // ignore: deprecated_member_use
    var widget = await builder.resolveIdentifier(
        Uri.parse('package:flutter/src/widgets/framework.dart'), 'Widget');


    final typedX = await builder.resolve(NamedTypeAnnotationCode(name: x));
    final typedModifier = await builder.resolve(
        NamedTypeAnnotationCode(name: modifier));

    final typedParameters = <TypedFormalParameterDeclaration>[];
    bool hasX = false;
    for (var e in allParameters) {
      final pt = await builder.resolve(e.type.code);
      final isX = await pt.isExactly(typedX);
      if (await pt.isExactly(typedModifier)) {
        throw DiagnosticException(Diagnostic(
            DiagnosticMessage(
                'FunctionWidget Cannot contain Modifier type parameters',
                target: function.asDiagnosticTarget),
            Severity.error));
      }
      // print(_printParts(e.type.code.parts));
      typedParameters.add(
          TypedFormalParameterDeclaration(parameter: e, type: pt)
            ..isX = isX);
      hasX |= isX;
    }

    final noXParameters = typedParameters.where((e) => !e.isX).map((e) =>
    e.parameter);
    final noXPositionalParametersRequired = noXParameters.where((e) =>
    !e.isNamed && e.isRequired);
    final noXPositionalParametersNotRequired = noXParameters.where((e) =>
    !e.isNamed && !e.isRequired);
    if (noXPositionalParametersNotRequired.isNotEmpty) {
      throw DiagnosticException(Diagnostic(
          DiagnosticMessage(
              'FunctionWidget Function Cannot contain not required parameters',
              target: function.asDiagnosticTarget),
          Severity.error));
    }
    final noXNamedParameters = noXParameters.where((e) => e.isNamed);


    final extParts = <Object>[
      'extension F\$$fName on ',
      f,
      ' { ',
      function.returnType.code,
      ' $fName(',
      for(var p in noXPositionalParametersRequired)
        DeclarationCode.fromParts([
          p.code, ','
        ]),
      '{',
      modifier,
      ' modifier = ',
      modifior,
      ',',
      ...noXNamedParameters.map((e) => [e.code, ',']).expand((e) => e),
      '})',
      '=>',
      fx,
      '(',
      'key: ',
      fxKey,
      '("$fName",[',
      ...noXParameters.map((e) => [e.name, ',']).expand((e) => e),
      ']),',
      'builder: (x) =>',
      'modifier.apply(',
      'x,',
      '$functionName(',
      for(var p in typedParameters)
        DeclarationCode.fromParts([
          if(!p.parameter.isNamed && p.isX)
            'x,',
          if(!p.parameter.isNamed && !p.isX)
            DeclarationCode.fromParts([p.parameter.name, ',']),
          if(p.parameter.isNamed && p.isX)
            DeclarationCode.fromParts(
                [p.parameter.name, ':', 'x', ',']),
          if(p.parameter.isNamed && !p.isX)
            DeclarationCode.fromParts(
                [p.parameter.name, ':', p.parameter.name, ',']),
        ]),
      ')',
      ')',
      ');',
      '}',
    ];
    // print(_printParts(extParts));

    builder.declareInLibrary(DeclarationCode.fromParts(extParts));
  }

  //用来识别 Modifier
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    // print('buildDeclarationsForClass ${clazz.identifier.name}');
    // // ignore: deprecated_member_use
    // final modifier = await builder.resolveIdentifier(_fLibrary, 'Modifier');
    //
    // final typedModifier = await builder.resolve(
    //     NamedTypeAnnotationCode(name: modifier));
    //
    // final clazzType = await builder.resolve(
    //     NamedTypeAnnotationCode(name: clazz.identifier));
    // if (await clazzType.isSubtypeOf(typedModifier)) {
    //   print('clazzType.isSubtype Modifier');
    //   await _buildCustomModifier(clazz, builder, modifier);
    // }


    //   if (c.length <= 1) {
    //     if (c.isNotEmpty) {
    //       if (c.single.isFactory) {
    //         throw '不可 Factory 构造函数';
    //       } else if (c.single.identifier.name.isNotEmpty) {
    //         throw '不可 命名 named 构造函数';
    //       }
    //     }
    //   } else {
    //     throw '过多的构造函数';
    //   }
  }

  Future<void> _buildCustomModifier(ClassDeclaration clazz,
      MemberDeclarationBuilder builder, Identifier modifier) async {
    final clazzName = clazz.identifier.name;
    final c = await builder.constructorsOf(clazz);
    final constructors = c.where((e) => !e.isFactory);
    final extName = _cModifierExtName(clazzName);
    if (extName.isEmpty) {
      throw DiagnosticException(Diagnostic(
          DiagnosticMessage(
              'FX The name must be included when customizing the Modifier',
              target: clazz.asDiagnosticTarget),
          Severity.error));
    }
    List parts = [];
    if (constructors.isEmpty) {
      parts.addAll([
        modifier,
        ' ',
        extName,
        '()',
        ' => ',
        'then(',
        clazz.identifier,
        '()',
        ')',
      ]);
    } else {
      for (var c in constructors) {
        final cName = c.identifier.name.capitalize;
        parts.addAll([
          modifier,
          ' ',
          extName,
          cName,
          '(',
          ')',
          ' => ',
          'then(',
          clazz.identifier,
          if(cName.isNotEmpty)'.',
          if(cName.isNotEmpty)c.identifier.name,
          '(',
          ')',
          ')',
        ]);
      }
    }


    List codes = [
      'extension \$$clazzName on ',
      modifier,
      ' {',
      ...parts,
      '}',
    ];

    print(_printParts(codes));
  }

  String _cModifierExtName(String clazzName) {
    String extName = clazzName;
    while (extName.startsWith('_')) {
      extName = extName.substring(1);
    }
    while (extName.toLowerCase().startsWith('modifier')) {
      extName = extName.substring(8);
    }
    while (extName.toLowerCase().endsWith('modifier')) {
      extName = extName.substring(0, extName.length - 8);
    }
    return extName.uncapitalize;
  }

}


String _printParts(Iterable parts) {
  String msg = '';
  for (var o in parts) {
    if (o is String) {
      msg += o;
    } else if (o is num || o is bool) {
      msg += o.toString();
    } else if (o is Identifier) {
      msg += o.name;
    } else if (o is Code) {
      msg += _printParts(o.parts);
    } else if (o is Iterable) {
      msg += _printParts(o);
    }
  }
  return msg;
}
extension _ on String {
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get uncapitalize =>
      isEmpty ? '' : '${this[0].toLowerCase()}${substring(1)}';
}

class TypedFormalParameterDeclaration {
  final FormalParameterDeclaration parameter;
  final StaticType type;
  late final bool isX;

  TypedFormalParameterDeclaration(
      {required this.parameter, required this.type});
}