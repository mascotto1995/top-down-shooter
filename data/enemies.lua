return {
    grunt = {
        name = "Grunt",
        health = 20,
        speed = 60,
        damage = 10,
        points = 10,
        sprite = "",
        width = 24,
        height = 24,
        behaviors = {"patrol_halls"},
        drop_chances = {
            health_pack = 0.1,
            ammo = 0.15,
            coins = 0.3
        },
        sounds = {
            death = "enemy-death.mp3",
            hurt = "enemy-hit.mp3"
        }
    },
    brute = {
        name = "Brute",
        health = 70,
        speed = 25,
        damage = 30,
        points = 20,
        sprite = "",
        width = 32,
        height = 32,
        behaviors = {"charge_attack"},
        armor = 2,
        charge_speed = 150,
        charge_cooldown = 10
    }
}