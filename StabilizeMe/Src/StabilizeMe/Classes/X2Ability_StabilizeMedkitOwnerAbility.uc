/**
 * A new ability that allows any soldier to stabilize any bleeding out medkit owner.
 */
class X2Ability_StabilizeMedkitOwnerAbility extends X2Ability 
	config(GameCore);


var config float CARRY_UNIT_RANGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;	
	Templates.AddItem(AddStabilizeMedkitOwnerAbility());	
	return Templates;
}


static function X2AbilityTemplate AddStabilizeMedkitOwnerAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Single            SingleTarget;
	local X2Condition_UnitProperty          TargetCondition, ShooterCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local X2Effect_RemoveEffects            RemoveEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'StabilizeMedkitOwner');
	
	// Costs one action point, just like normal stabilize.
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	// Standard restrictions apply to the operator; must be alive, must not be panicked, etc.
	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);
	Template.AddShooterEffectExclusions();
	
	// The target conditions: Must be a friendly, must be within carry range, must be bleeding out.
	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.CanBeCarried = true;
	TargetCondition.ExcludeAlive = false;               
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeHostileToSource = true;     
	TargetCondition.RequireWithinRange = true;
	TargetCondition.IsBleedingOut = true;
	TargetCondition.WithinRange = default.CARRY_UNIT_RANGE; // this does nothing apparently.
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// This is where we check that the target unit has a usable medkit.
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_StabilizeMedkitOwner');	

	// Ability removes the bleeding out effect. Once removed, the target becomes unconscious.
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);
	Template.AddTargetEffect(RemoveEffects);
	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateUnconsciousStatusEffect());
	
	SingleTarget = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = SingleTarget;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stabilize";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STABILIZE_PRIORITY;
	Template.Hostility = eHostility_Defensive;
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;

	Template.ActivationSpeech = 'StabilizingAlly';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	`log("->(StabilizeMe) AddStabilizeMedkitOwnerAbility has been run.");

	return Template;
}
